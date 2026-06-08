"""Input sanitization for user-submitted business ideas."""

from __future__ import annotations

import base64
import binascii
import html
import re
import unicodedata
import urllib.parse
from contextlib import suppress
from dataclasses import dataclass

from app.core.logging import get_logger

logger = get_logger(__name__)


@dataclass(frozen=True)
class SanitizationResult:
    """Result of sanitizing a user-submitted idea."""

    is_safe: bool
    sanitized_text: str
    reason: str | None
    flagged_patterns: list[str]


@dataclass(frozen=True)
class _PatternRule:
    """Named regex used for safe logging and diagnostics."""

    name: str
    pattern: re.Pattern[str]
    guidance_reason: bool = False


class SanitizationService:
    """Detect prompt injection and unsafe non-business content."""

    GUIDANCE_MESSAGE = "Add more detail about your business idea for better results"
    INJECTION_MESSAGE = "Potential prompt injection detected. Please describe your business idea directly."
    _ZERO_WIDTH_CHARACTERS = "\u200b\u200c\u200d\u200e\u200f\ufeff\u2060\u2061\u2062\u2063"
    _RULES = [
        _PatternRule(
            "ignore_previous_instructions",
            re.compile(r"ignore\s+(all\s+)?previous\s+instructions", re.IGNORECASE),
        ),
        _PatternRule(
            "forget_prior_context",
            re.compile(r"forget\s+(all\s+|everything\s+)?(you\s+)?(know|were\s+told)", re.IGNORECASE),
        ),
        _PatternRule("you_are_now", re.compile(r"you\s+are\s+now\s+(?:a\s+)?(?:an?\s+)?", re.IGNORECASE)),
        _PatternRule(
            "new_system_instructions",
            re.compile(r"new\s+(?:system\s+)?instructions?\s*[:\uff1a]", re.IGNORECASE),
        ),
        _PatternRule(
            "system_prompt",
            re.compile(r"system\s*(?:prompt|message)\s*[:\uff1a]?", re.IGNORECASE),
        ),
        _PatternRule(
            "safety_override",
            re.compile(r"(?:override|bypass|disable)\s+(?:safety|security|filter|guard)", re.IGNORECASE),
        ),
        _PatternRule("act_as", re.compile(r"act\s+as\s+(?:a\s+)?(?:an?\s+)?", re.IGNORECASE)),
        _PatternRule("dan_or_developer_mode", re.compile(r"(?:DAN|developer)\s+mode", re.IGNORECASE)),
        _PatternRule("jailbreak", re.compile(r"jailbreak", re.IGNORECASE)),
        _PatternRule("pretend_or_imagine", re.compile(r"(?:pretend|imagine)\s+(?:you\s+are|that)", re.IGNORECASE)),
        _PatternRule(
            "do_not_follow_rules",
            re.compile(r"do\s+not\s+follow\s+(?:any\s+)?(?:rules|guidelines|instructions)", re.IGNORECASE),
        ),
        _PatternRule(
            "reveal_system_prompt",
            re.compile(r"(?:reveal|show|print|output)\s+(?:your\s+)?(?:system\s+)?prompt", re.IGNORECASE),
        ),
        _PatternRule(
            "html_tag_payload",
            re.compile(r"<\s*(?:script|iframe|img|svg|object|embed|form|a|input|body)\b", re.IGNORECASE),
            guidance_reason=True,
        ),
        _PatternRule(
            "sql_injection",
            re.compile(
                r"\b(?:UNION|SELECT|DROP|INSERT|DELETE|UPDATE)\b\s+.*\b(?:FROM|INTO|TABLE|DATABASE|WHERE)\b",
                re.IGNORECASE,
            ),
            guidance_reason=True,
        ),
        _PatternRule(
            "code_execution_payload",
            re.compile(r"(?:def\s+\w+\s*\(|os\.system|subprocess\.|eval\s*\(|exec\s*\()", re.IGNORECASE),
            guidance_reason=True,
        ),
    ]

    def sanitize(self, text: str) -> SanitizationResult:
        """Return sanitized text and safety metadata for a submitted idea."""
        sanitized_text = self._normalize_text(text).strip()
        flagged_patterns, use_guidance = self._detect_patterns(sanitized_text)

        if len(sanitized_text) < 10:
            return SanitizationResult(
                is_safe=False,
                sanitized_text=sanitized_text,
                reason=self.GUIDANCE_MESSAGE,
                flagged_patterns=flagged_patterns,
            )

        if flagged_patterns:
            logger.warning(
                "Unsafe idea content detected; flagged_patterns=%s",
                flagged_patterns,
                extra={"extra_data": {"flagged_patterns": flagged_patterns}},
            )
            return SanitizationResult(
                is_safe=False,
                sanitized_text=sanitized_text,
                reason=self.GUIDANCE_MESSAGE if use_guidance else self.INJECTION_MESSAGE,
                flagged_patterns=flagged_patterns,
            )

        return SanitizationResult(
            is_safe=True,
            sanitized_text=sanitized_text,
            reason=None,
            flagged_patterns=[],
        )

    @classmethod
    def _normalize_text(cls, text: str) -> str:
        """Normalize Unicode to NFKC and strip zero-width characters."""
        normalized = unicodedata.normalize("NFKC", text)
        for char in cls._ZERO_WIDTH_CHARACTERS + "\x00":
            normalized = normalized.replace(char, "")
        return normalized

    def _detect_patterns(self, text: str) -> tuple[list[str], bool]:
        candidates = [text, *self._decoded_variants(text)]
        flagged_patterns: list[str] = []
        use_guidance = False

        for rule in self._RULES:
            if any(rule.pattern.search(candidate) for candidate in candidates):
                flagged_patterns.append(rule.name)
                use_guidance = use_guidance or rule.guidance_reason

        return flagged_patterns, use_guidance

    @staticmethod
    def _decoded_variants(text: str) -> list[str]:
        variants: list[str] = []
        compact = re.sub(r"\s+", "", text)
        
        variants.append(urllib.parse.unquote(text))
        variants.append(html.unescape(text))
    
        padded_compact = compact + "=" * (-len(compact) % 4)
        try:
            decoded = base64.b64decode(padded_compact, validate=True).decode("utf-8")
        except (binascii.Error, UnicodeDecodeError, ValueError):
            decoded = ""
        if decoded:
            variants.append(decoded)

        if re.fullmatch(r"[0-9a-fA-F]+", compact or "") and len(compact) % 2 == 0:
            with suppress(UnicodeDecodeError):
                variants.append(bytes.fromhex(compact).decode("utf-8"))

        return variants

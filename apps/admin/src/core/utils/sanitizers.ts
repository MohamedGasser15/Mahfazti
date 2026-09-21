import React from 'react';

// Regular expressions for Arabic and English characters
export const ARABIC_REGEX = /[\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF\uFB50-\uFDFF\uFE70-\uFEFF\u0660-\u0669]/;
export const ARABIC_GLOBAL_REGEX = /[\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF\uFB50-\uFDFF\uFE70-\uFEFF\u0660-\u0669]/g;
export const ENGLISH_GLOBAL_REGEX = /[a-zA-Z]/g;

/**
 * Sanitizes input to prevent typing or pasting Arabic characters.
 * Restricts to English/ASCII letters, numbers, spaces, and punctuation.
 */
export const sanitizeEnglishInput = (value: string, allowSpaces: boolean = true): string => {
  let cleaned = value.replace(ARABIC_GLOBAL_REGEX, '');
  if (!allowSpaces) {
    cleaned = cleaned.replace(/\s+/g, '');
  }
  return cleaned;
};

/**
 * Sanitizes input to prevent typing or pasting English letters.
 * Allows Arabic letters, numbers (Arabic & Western), Arabic punctuation, spaces, and common symbols.
 */
export const sanitizeArabicInput = (value: string): string => {
  return value.replace(ENGLISH_GLOBAL_REGEX, '');
};

/**
 * KeyDown handler to block Arabic keystrokes on English-only inputs.
 */
export const handleEnglishOnlyKeyDown = (
  e: React.KeyboardEvent<HTMLInputElement | HTMLTextAreaElement>,
  allowSpaces: boolean = true
) => {
  if (e.key.length !== 1 || e.ctrlKey || e.altKey || e.metaKey) {
    return;
  }
  if (!allowSpaces && e.key === ' ') {
    e.preventDefault();
    return;
  }
  if (ARABIC_REGEX.test(e.key)) {
    e.preventDefault();
  }
};

/**
 * KeyDown handler to block English letter keystrokes on Arabic-only inputs.
 */
export const handleArabicOnlyKeyDown = (
  e: React.KeyboardEvent<HTMLInputElement | HTMLTextAreaElement>
) => {
  if (e.key.length !== 1 || e.ctrlKey || e.altKey || e.metaKey) {
    return;
  }
  if (/[a-zA-Z]/.test(e.key)) {
    e.preventDefault();
  }
};

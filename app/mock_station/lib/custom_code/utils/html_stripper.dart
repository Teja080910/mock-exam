// HTML tag removal utility functions
import 'dart:convert';

/// Strips HTML tags from a string and returns clean text
String stripHtmlTags(String htmlString) {
  if (htmlString.isEmpty) return '';
  
  // Remove HTML tags using regex
  String cleanText = htmlString.replaceAll(RegExp(r'<[^>]*>'), '');
  
  // Decode HTML entities
  cleanText = cleanText
      .replaceAll('&quot;', '"')
      .replaceAll('&amp;', '&')
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll('&nbsp;', ' ')
      .replaceAll('&#39;', "'")
      .replaceAll('&apos;', "'");
  
  // Clean up extra whitespace
  cleanText = cleanText.replaceAll(RegExp(r'\s+'), ' ').trim();
  
  return cleanText;
}

/// Alternative method using html package if available
String stripHtmlTagsAdvanced(String htmlString) {
  if (htmlString.isEmpty) return '';
  
  try {
    // Simple regex-based approach for common HTML tags
    String cleanText = htmlString
        .replaceAll(RegExp(r'<p[^>]*>', caseSensitive: false), '')
        .replaceAll(RegExp(r'</p>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'<br[^>]*>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'<b[^>]*>', caseSensitive: false), '')
        .replaceAll(RegExp(r'</b>', caseSensitive: false), '')
        .replaceAll(RegExp(r'<strong[^>]*>', caseSensitive: false), '')
        .replaceAll(RegExp(r'</strong>', caseSensitive: false), '')
        .replaceAll(RegExp(r'<i[^>]*>', caseSensitive: false), '')
        .replaceAll(RegExp(r'</i>', caseSensitive: false), '')
        .replaceAll(RegExp(r'<em[^>]*>', caseSensitive: false), '')
        .replaceAll(RegExp(r'</em>', caseSensitive: false), '')
        .replaceAll(RegExp(r'<u[^>]*>', caseSensitive: false), '')
        .replaceAll(RegExp(r'</u>', caseSensitive: false), '')
        .replaceAll(RegExp(r'<span[^>]*>', caseSensitive: false), '')
        .replaceAll(RegExp(r'</span>', caseSensitive: false), '')
        .replaceAll(RegExp(r'<div[^>]*>', caseSensitive: false), '')
        .replaceAll(RegExp(r'</div>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'<[^>]*>'), ''); // Remove any remaining HTML tags
    
    // Decode HTML entities
    cleanText = cleanText
        .replaceAll('&quot;', '"')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&#39;', "'")
        .replaceAll('&apos;', "'")
        .replaceAll('&hellip;', '...')
        .replaceAll('&mdash;', '—')
        .replaceAll('&ndash;', '–');
    
    // Clean up extra whitespace and newlines
    cleanText = cleanText
        .replaceAll(RegExp(r'\n\s*\n'), '\n') // Remove multiple newlines
        .replaceAll(RegExp(r'[ \t]+'), ' ') // Replace multiple spaces/tabs with single space
        .trim();
    
    return cleanText;
  } catch (e) {
    // Fallback to simple regex if advanced parsing fails
    return stripHtmlTags(htmlString);
  }
}



import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:qubic_ai/core/themes/colors.dart';
import 'package:qubic_ai/core/utils/extensions/extensions.dart';
import 'package:qubic_ai/core/utils/helper/custom_toast.dart';

import '../utils/helper/clipboard.dart';
import '../utils/helper/regexp_methods.dart';

class PreBlockBuilder extends MarkdownElementBuilder {
  final BuildContext? context;

  PreBlockBuilder([this.context]);

  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    final content = _extractCodeContent(element);
    final language = _getCodeLanguage(element);
    return _buildCodeBlock(content, language);
  }

  String _extractCodeContent(md.Element element) {
    return element.children
            ?.whereType<md.Element>()
            .firstWhere((e) => e.tag == 'code')
            .textContent ??
        element.textContent;
  }

  String _getCodeLanguage(md.Element element) {
    return element.children
            ?.whereType<md.Element>()
            .firstWhere(
              (e) => e.tag == 'code',
              orElse: () => md.Element('', []),
            )
            .attributes['class']
            ?.replaceAll('language-', '') ??
        'dart';
  }

  Widget _buildCodeBlock(String content, String language) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildCodeHeader(language, content),
        Container(
          decoration: BoxDecoration(
            color: ColorManager.codeBlockBg,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(4),
              bottomRight: Radius.circular(4),
            ),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SelectableText.rich(
              TextSpan(
                children: _parseCode(content, language),
                style: const TextStyle(
                  fontFamily: 'Consolas',
                  fontSize: 14,
                  color: ColorManager.codeBaseText,
                ),
              ),
            ).withAllPadding(12),
          ),
        ),
      ],
    );
  }

  Widget _buildCodeHeader(String language, String content) {
    return Container(
      padding: const EdgeInsets.only(left: 12, top: 8, bottom: 8),
      decoration: const BoxDecoration(
        color: ColorManager.codeHeaderBg,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(4),
          topRight: Radius.circular(4),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            language.toUpperCase(),
            style: const TextStyle(
              color: ColorManager.codeHeaderText,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          InkWell(
            onTap: () {
              ClipboardManager.copyToClipboard(content);
              context != null
                  ? showCustomToast(context!,
                      message: 'Code copied to clipboard')
                  : null;
            },
            child: const Icon(
              Icons.copy,
              color: ColorManager.codeHeaderIcon,
              size: 16,
            ).withSymmetricPadding(horizontal: 12),
          ),
        ],
      ),
    );
  }

  List<TextSpan> _parseCode(String content, String language) {
    final List<TextSpan> spans = [];

    final matches = RegExpManager.syntaxPatterns.allMatches(content);
    int lastIndex = 0;

    for (final match in matches) {
      if (match.start > lastIndex) {
        spans.add(TextSpan(
          text: content.substring(lastIndex, match.start),
          style: const TextStyle(color: ColorManager.codeBaseText),
        ));
      }

      final String? annotation = match.namedGroup('annotation');
      final String? comment = match.namedGroup('comment');
      final String? string = match.namedGroup('string');
      final String? keyword = match.namedGroup('keyword');
      final String? type = match.namedGroup('type');
      final String? number = match.namedGroup('number');
      final String? symbol = match.namedGroup('symbol');
      final String? classGroup = match.namedGroup('class');
      final String? function = match.namedGroup('function');
      final String? variable = match.namedGroup('variable');

      if (annotation != null) {
        spans.add(TextSpan(
          text: annotation,
          style: const TextStyle(color: ColorManager.codeKeyword),
        ));
      } else if (comment != null) {
        spans.add(TextSpan(
          text: comment,
          style: const TextStyle(color: ColorManager.codeComment),
        ));
      } else if (string != null) {
        spans.add(TextSpan(
          text: string,
          style: const TextStyle(color: ColorManager.codeString),
        ));
      } else if (keyword != null) {
        spans.add(TextSpan(
          text: keyword,
          style: const TextStyle(color: ColorManager.codeKeyword),
        ));
      } else if (type != null) {
        spans.add(TextSpan(
          text: type,
          style: const TextStyle(color: ColorManager.codeType),
        ));
      } else if (number != null) {
        spans.add(TextSpan(
          text: number,
          style: const TextStyle(color: ColorManager.codeNumber),
        ));
      } else if (symbol != null) {
        spans.add(TextSpan(
          text: symbol,
          style: const TextStyle(color: ColorManager.codeSymbol),
        ));
      } else if (classGroup != null) {
        spans.add(TextSpan(
          text: classGroup,
          style: const TextStyle(color: ColorManager.codeClass),
        ));
      } else if (function != null) {
        spans.add(TextSpan(
          text: function,
          style: const TextStyle(color: ColorManager.codeFunction),
        ));
      } else if (variable != null) {
        spans.add(TextSpan(
          text: variable,
          style: const TextStyle(color: ColorManager.codeVariable),
        ));
      }

      lastIndex = match.end;
    }

    if (lastIndex < content.length) {
      spans.add(TextSpan(
        text: content.substring(lastIndex),
        style: const TextStyle(color: ColorManager.codeBaseText),
      ));
    }

    return spans;
  }
}

class InlineCodeBuilder extends MarkdownElementBuilder {
  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: ColorManager.inlineCodeBg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: SelectableText(
        element.textContent,
        style: const TextStyle(
          fontFamily: 'Consolas',
          fontSize: 14,
          color: ColorManager.inlineCodeText,
        ),
      ),
    );
  }
}

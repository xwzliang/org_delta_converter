import 'dart:convert';

import 'package:flutter_quill/flutter_quill.dart';
import 'package:org_delta_converter/src/constants_provider.dart';
import 'package:path/path.dart' as p;

/// Convert from delta to org object defined by org_parser
class DeltaToOrgStringConverter extends Converter<Delta, String> {
  final _orgStringLines = <String>[];

  // Make all sections sepcified number levels up
  int promoteLevel;
  // Make all sections sepcified number levels down
  int demoteLevel;
  // If not null, convert file path to relative path
  String? basePathForConvertFilePathToRelativePath;

  DeltaToOrgStringConverter({
    this.promoteLevel = 0,
    this.demoteLevel = 0,
    this.basePathForConvertFilePathToRelativePath,
  });

  @override
  String convert(Delta input) {
    for (var i = 0; i < input.length; i++) {
      final operation = input[i];
      if (operation.isInsert) {
        if (operation.value is String) {
          var text = operation.value as String;
          if (operation.isPlain) {
            if (text.contains('\n')) {
              // _orgStringLines.addAll(text.trim().split('\n'));
              text.splitMapJoin('\n\n', onMatch: (match) {
                _orgStringLines.add('\n');
                return '';
              }, onNonMatch: (nonMatch) {
                if (nonMatch.isNotEmpty) {
                  // _orgStringLines.addAll(nonMatch.split('\n'));
                  if (_orgStringLines.isEmpty) {
                    _orgStringLines.add(nonMatch);
                  } else {
                    final lastLine = _orgStringLines.last;
                    _orgStringLines.last = '$lastLine$nonMatch';
                  }
                }
                return '';
              });
            } else {
              if (_orgStringLines.isEmpty) {
                _orgStringLines.add(text);
              } else {
                final lastLine = _orgStringLines.last;
                _orgStringLines.last = '$lastLine$text';
              }
            }
          } else {
            final attributes = operation.attributes!;
            if (attributes.containsKey(Attribute.link.key)) {
              if (!attributes[Attribute.link.key]
                  .startsWith(ConstantsProvider.orgHttpLinkPrefix)) {
                // http link use original text, other link use org link
                text = '[[${attributes[Attribute.link.key]}][$text]]';
              }
              if (_orgStringLines.isEmpty) {
                _orgStringLines.add(text);
              } else {
                final lastLine = _orgStringLines.last;
                _orgStringLines.last = '$lastLine$text';
              }
            }
            if (attributes.containsKey(Attribute.header.key)) {
              final lastLine = _orgStringLines.last;
              _orgStringLines.last =
                  '${"*" * (attributes[Attribute.header.key] - promoteLevel + demoteLevel)} $lastLine';
              // Add a new line
              if (!lastLine.endsWith('\n')) {
                _orgStringLines.add('');
              }
            }
            if (attributes.containsKey(Attribute.list.key)) {
              final lastLine = _orgStringLines.last;
              // ordered list
              if (attributes[Attribute.list.key] ==
                  ConstantsProvider.deltaListAttributeOrderedValue) {
                final newlinesInOrgStringLinesLastLine = lastLine.split('\n');
                newlinesInOrgStringLinesLastLine.last =
                    '1. ${newlinesInOrgStringLinesLastLine.last}';
                _orgStringLines.last =
                    newlinesInOrgStringLinesLastLine.join('\n');
                // Add a new line for next list item
                _orgStringLines.add('');
              } else if (attributes[Attribute.list.key] ==
                  ConstantsProvider.deltaListAttributeUnorderedValue) {
                final newlinesInOrgStringLinesLastLine = lastLine.split('\n');
                newlinesInOrgStringLinesLastLine.last =
                    '- ${newlinesInOrgStringLinesLastLine.last}';
                _orgStringLines.last =
                    newlinesInOrgStringLinesLastLine.join('\n');
                // Add a new line for next list item
                _orgStringLines.add('');
              }
            }
          }
        } else if (operation.value is Map) {
          var contentMap = operation.value as Map<String, dynamic>;
          if (contentMap.containsKey(BlockEmbed.imageType)) {
            final imagePath = contentMap[BlockEmbed.imageType] as String;
            if (basePathForConvertFilePathToRelativePath == null) {
              _orgStringLines.add('[[file:$imagePath]]');
            } else {
              final imageRelativePath = p.relative(imagePath,
                  from: basePathForConvertFilePathToRelativePath);
              _orgStringLines.add('[[file:$imageRelativePath]]');
            }
          }
        }
      }
    }
    String orgStringJoinedLinesString = _orgStringLines.join('\n');
    if (!orgStringJoinedLinesString.endsWith('\n')) {
      // Ensure a newline at the last
      orgStringJoinedLinesString = '$orgStringJoinedLinesString\n';
    }
    return orgStringJoinedLinesString;
  }
}

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
            // _orgStringLines.addAll(text.trim().split('\n'));
            text.splitMapJoin('\n\n', onMatch: (match) {
              _orgStringLines.add('');
              return '';
            }, onNonMatch: (nonMatch) {
              if (nonMatch.isNotEmpty) {
                _orgStringLines.addAll(nonMatch.split('\n'));
              }
              return '';
            });
          } else {
            final attributes = operation.attributes!;
            if (attributes.containsKey(Attribute.link.key)) {
              if (!attributes[Attribute.link.key]
                  .startsWith(ConstantsProvider.orgHttpLinkPrefix)) {
                // http link use original text, other link use org link
                text = '[[${attributes[Attribute.link.key]}][$text]]';
              }
              _orgStringLines.add(text);
            }
            if (attributes.containsKey(Attribute.header.key)) {
              final lastLine = _orgStringLines.last;
              _orgStringLines.last =
                  '${"*" * (attributes[Attribute.header.key] - promoteLevel + demoteLevel)} $lastLine';
            }
            if (attributes.containsKey(Attribute.list.key)) {
              final lastLine = _orgStringLines.last;
              if (attributes[Attribute.list.key] ==
                  ConstantsProvider.deltaListAttributeOrderedValue) {
                // ordered list
                _orgStringLines.last = '1. $lastLine';
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
    return '${_orgStringLines.join("\n")}\n';
  }
}

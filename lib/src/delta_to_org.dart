import 'dart:convert';

import 'package:flutter_quill/flutter_quill.dart';

/// Convert from delta to org object defined by org_parser
class DeltaToOrgStringConverter extends Converter<Delta, String> {
  final _orgStringLines = <String>[];

  // Make all sections sepcified number levels up
  int promoteLevel;
  // Make all sections sepcified number levels down
  int demoteLevel;

  DeltaToOrgStringConverter({this.promoteLevel = 0, this.demoteLevel = 0});

  @override
  String convert(Delta input) {
    for (var i = 0; i < input.length; i++) {
      final operation = input[i];
      if (operation.isInsert) {
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
            text = '[[${attributes[Attribute.link.key]}][$text]]';
            _orgStringLines.add(text);
          }
          if (attributes.containsKey(Attribute.header.key)) {
            final lastLine = _orgStringLines.last;
            _orgStringLines.last =
                '${"*" * (attributes[Attribute.header.key] - promoteLevel + demoteLevel)} $lastLine';
          }
        }
      }
    }
    return _orgStringLines.join('\n');
  }
}

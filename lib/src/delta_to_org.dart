import 'dart:convert';

import 'package:flutter_quill/flutter_quill.dart';

/// Convert from delta to org object defined by org_parser
class DeltaToOrgStringConverter extends Converter<Delta, String> {
  final _orgStringLines = <String>[];

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
              _orgStringLines.add(nonMatch);
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
                '${"*" * attributes[Attribute.header.key]} $lastLine';
          }
        }
      }
    }
    return _orgStringLines.join('\n');
  }
}

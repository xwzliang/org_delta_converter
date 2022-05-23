import 'dart:convert';

import 'package:flutter_quill/flutter_quill.dart';
import 'package:org_parser/org_parser.dart';

/// Convert from org object parsed by package org_parser to delta
class OrgToDelta {}

/// Convert from org object parsed by package org_parser to delta
class OrgNodesToDeltaConverter extends Converter<List<OrgNode>, Delta> {
  final _delta = Delta();

  @override
  Delta convert(List<OrgNode>? input) {
    if (input != null) {
      orgNodeListToDelta(input);
    }
    return _delta;
  }

  void orgNodeListToDelta(List<OrgNode> orgNodes) {
    for (final orgNode in orgNodes) {
      orgNodeToDelta(orgNode);
    }
  }

  void orgNodeToDelta(OrgNode orgNode) {
    if (orgNode is OrgPlainText) {
      _delta.insert(orgNode.content);
    } else if (orgNode is OrgLink) {
      _delta.insert(orgNode.description, {
        Attribute.link.key: orgNode.location,
      });
    } else if (orgNode is OrgSection) {
      _delta.insert(orgNode.headline.rawTitle);
      _delta.insert('\n', {
        Attribute.header.key: orgNode.headline.level,
        // Attribute.indent.key: orgNode.headline.level - 1,
      });
      if (orgNode.content != null) {
        orgNodeToDelta(orgNode.content!);
      }
      orgNodeListToDelta(orgNode.sections);
    } else if (orgNode is OrgContent) {
      orgNodeListToDelta(orgNode.children);
    } else if (orgNode is OrgParagraph) {
      orgNodeListToDelta(orgNode.body.children);
    }
  }
}

import 'dart:convert';

import 'package:flutter_quill/flutter_quill.dart';
import 'package:org_delta_converter/src/constants_provider.dart';
import 'package:org_parser/org_parser.dart';
import 'package:path/path.dart' as p;

/// Convert from org object parsed by package org_parser to delta
class OrgToDelta {}

/// Convert from org object parsed by package org_parser to delta
class OrgNodesToDeltaConverter extends Converter<List<OrgNode>, Delta> {
  final _delta = Delta();
  // Make all sections sepcified number levels up
  int promoteLevel;
  // Make all sections sepcified number levels down
  int demoteLevel;
  // If not null, convert file path to full path
  String? basePathForConvertFilePathToFullPath;

  OrgNodesToDeltaConverter({
    this.promoteLevel = 0,
    this.demoteLevel = 0,
    this.basePathForConvertFilePathToFullPath,
  });

  @override
  Delta convert(List<OrgNode>? input) {
    if (input != null) {
      orgNodeListToDelta(input);
    }
    return _delta;
  }

  void orgNodeListToDelta(List<OrgNode> orgNodes, {bool shouldTrim = false}) {
    for (final orgNode in orgNodes) {
      orgNodeToDelta(orgNode, shouldRemoveTrailingNewline: shouldTrim);
    }
  }

  void orgNodeToDelta(OrgNode orgNode,
      {bool shouldRemoveTrailingNewline = false}) {
    // print(orgNode);
    if (orgNode is OrgPlainText) {
      if (shouldRemoveTrailingNewline) {
        _delta.insert(orgNode.content.replaceFirst(RegExp(r'\n+$'), ''));
      } else {
        _delta.insert(orgNode.content);
      }
    } else if (orgNode is OrgList) {
      for (final orgListItem in orgNode.items) {
        if (orgListItem is OrgListOrderedItem) {
          // _delta.insert(orgListItem.body);
          orgNodeToDelta(orgListItem.body!, shouldRemoveTrailingNewline: true);
          _delta.insert('\n', {
            Attribute.list.key: ConstantsProvider.deltaListAttributeOrderedValue
          });
        }
      }
    } else if (orgNode is OrgLink) {
      if (orgNode.location.startsWith(ConstantsProvider.orgFileLinkPrefix)) {
        // Handle file link

        final orgParsedFileLink =
            orgFileLink.parse(orgNode.location).value as OrgFileLink;
        final filePathInLink = orgParsedFileLink.body;
        final fileExtension = p.extension(filePathInLink);
        final fileExtensionWithoutDot = fileExtension.substring(1);
        // Is image
        if (ConstantsProvider.imageFileNameExtensions
            .contains(fileExtensionWithoutDot.toLowerCase())) {
          if (orgParsedFileLink.isRelative &&
              basePathForConvertFilePathToFullPath != null) {
            final fileFullPath = p.normalize(
                p.join(basePathForConvertFilePathToFullPath!, filePathInLink));
            _delta.insert({BlockEmbed.imageType: fileFullPath});
          } else {
            _delta.insert({BlockEmbed.imageType: filePathInLink});
          }
        }
      } else if (orgNode.location
          .startsWith(ConstantsProvider.orgHttpLinkPrefix)) {
        _delta.insert(orgNode.location, {
          Attribute.link.key: orgNode.location,
        });
      } else {
        _delta.insert(orgNode.description, {
          Attribute.link.key: orgNode.location,
        });
      }
    } else if (orgNode is OrgSection) {
      _delta.insert(orgNode.headline.rawTitle);
      _delta.insert('\n', {
        Attribute.header.key:
            orgNode.headline.level - promoteLevel + demoteLevel,
        // Attribute.indent.key: orgNode.headline.level - 1,
      });
      if (orgNode.content != null) {
        orgNodeToDelta(orgNode.content!,
            shouldRemoveTrailingNewline: shouldRemoveTrailingNewline);
      }
      orgNodeListToDelta(orgNode.sections,
          shouldTrim: shouldRemoveTrailingNewline);
    } else if (orgNode is OrgContent) {
      orgNodeListToDelta(orgNode.children,
          shouldTrim: shouldRemoveTrailingNewline);
    } else if (orgNode is OrgParagraph) {
      orgNodeListToDelta(orgNode.body.children,
          shouldTrim: shouldRemoveTrailingNewline);
    }
  }
}

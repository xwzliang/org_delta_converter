import 'package:flutter_test/flutter_test.dart';

import 'package:org_delta_converter/org_delta_converter.dart';
import 'package:org_parser/org_parser.dart';

void main() {
  test('org file link', () {
    const orgString = 'file:../../resources/test.jpg';
    final orgDoc = OrgDocument.parse(orgString);
    final delta = OrgNodesToDeltaConverter(
            basePathForConvertFilePathToFullPath: '/root/dir/notes/permanent')
        .convert([orgDoc.content!]);
    expect(delta[0].value['image'], '/root/dir/resources/test.jpg');
  });
  test('org http link', () {
    const orgString = 'https://test.com';
    final orgDoc = OrgDocument.parse(orgString);
    final delta = OrgNodesToDeltaConverter().convert([orgDoc.content!]);
    final convertedOrgString = DeltaToOrgStringConverter().convert(delta);
    expect(convertedOrgString.trim(), orgString);
  });
  test('org ordered list', () {
    const orgString = '''
1. list one
1. list two
1. list three
''';
    final orgDoc = OrgDocument.parse(orgString);
    final delta = OrgNodesToDeltaConverter().convert([orgDoc.content!]);
    final convertedOrgString = DeltaToOrgStringConverter().convert(delta);
    // print(delta);
    // print(convertedOrgString);
    expect(convertedOrgString, orgString);
  });
  test('inline link', () {
    const orgString = '''
From the book  [[id:8186fa1d-caaf-48ec-930c-aceb69acf433][How to take smart notes : one simple technique to boost writing, learning and thinking--for students, academics and nonfiction book writers]], Ahrens said:
Also, I think this argument might be related to the reason why [[id:b504357e-8010-407a-a357-029301df6c67][The Feynman Technique]] works incredibly well for learning.
''';

    final orgDoc = OrgDocument.parse(orgString);
    final delta = OrgNodesToDeltaConverter().convert([orgDoc.content!]);
    final convertedOrgString = DeltaToOrgStringConverter().convert(delta);
    // print(delta);
    // print(convertedOrgString);
    expect(convertedOrgString, orgString);
  });
  test('org ordered list with inline link', () {
    const orgString = '''
1. list [[id:idtest][test link]] test test
1. list two
1. list three
1. list four
1. list five
''';
    final orgDoc = OrgDocument.parse(orgString);
    final delta = OrgNodesToDeltaConverter().convert([orgDoc.content!]);
    final convertedOrgString = DeltaToOrgStringConverter().convert(delta);
    expect(convertedOrgString, orgString);
  });
  test('complex org ordered list with inline link in section', () {
    const orgString = r'''
* content
1. list [[id:idtest][test link]] test test
1. list two
1. list three
1. list four
1. list five


''';
    const expectedConvertedOrgString = r'''
* content
1. list [[id:idtest][test link]] test test
1. list two
1. list three
1. list four
1. list five
''';

    final orgDoc = OrgDocument.parse(orgString);
    final delta = OrgNodesToDeltaConverter().convert(orgDoc.sections);
    final convertedOrgString = DeltaToOrgStringConverter().convert(delta);
    // print(delta);
    // print(convertedOrgString);
    expect(convertedOrgString, expectedConvertedOrgString);
  });
  test('complex org ordered list with inline link and content in section', () {
    const orgString = r'''
* content
test test
test test
1. list [[id:idtest][test link]] test test
1. list two
1. list three
1. list four
1. list five


''';
    const expectedConvertedOrgString = r'''
* content
test test
test test
1. list [[id:idtest][test link]] test test
1. list two
1. list three
1. list four
1. list five
''';

    final orgDoc = OrgDocument.parse(orgString);
    final delta = OrgNodesToDeltaConverter().convert(orgDoc.sections);
    final convertedOrgString = DeltaToOrgStringConverter().convert(delta);
    // print(delta);
    // print(convertedOrgString);
    expect(convertedOrgString, expectedConvertedOrgString);
  });
  test('org list with content', () {
    const orgString = '''
[[id:idtest][test link]]
1. list [[id:idtest][test link]] test test
[[id:idtest][test link]]
[[id:idtest][test link]]
2. list two
test test
[[id:idtest][test link]]
[[id:idtest][test link]]
''';
    final orgDoc = OrgDocument.parse(orgString);
    final delta = OrgNodesToDeltaConverter().convert([orgDoc.content!]);
    final convertedOrgString = DeltaToOrgStringConverter().convert(delta);
    expect(convertedOrgString, orgString);
  });
  test('org list with content which contains spaces at the beginning of line',
      () {
    const orgString = '''
[[id:idtest][test link]]
1. list [[id:idtest][test link]] test test
    [[id:idtest][test link]]
    [[id:idtest][test link]]
2. list two
    [[id:idtest][test link]]
    [[id:idtest][test link]]
''';
    final orgDoc = OrgDocument.parse(orgString);
    final delta = OrgNodesToDeltaConverter().convert([orgDoc.content!]);
    final convertedOrgString = DeltaToOrgStringConverter().convert(delta);
    expect(convertedOrgString, orgString);
  });
}

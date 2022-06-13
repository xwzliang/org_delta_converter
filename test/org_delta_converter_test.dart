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
    expect(convertedOrgString, orgString);
  });
}

export function regexTestCase(input) {
    const notLiteral = new RegExp("ab + c");
    const re = /error+here?/;

    notLiteral.test("something")
    re.test("something else")
}

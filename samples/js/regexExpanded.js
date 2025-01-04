export function regexTestCase(input) {
    const re = /^(?:\d{3}|\(\d{3}\))([-/.])\d{3}\1\d{4}$/;
    const another = /lol/;
    re.test(input)
}

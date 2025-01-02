// Single-line comment
/* Multi-line comment
   Explaining calculus implementation */

// Module imports/exports
export const EPSILON = 0.0001;

export const sin = (x) => {
  // Taylor series for sin(x)
  let term = x;
  let sum = x;
  for (let n = 1; n <= 10; n++) {
    term *= -x * x / ((2 * n + 1) * (2 * n));
    sum += term;
  }
  return sum;
};

export const cos = (x) => {
  // Taylor series for cos(x)
  let term = 1;
  let sum = 1;
  for (let n = 1; n <= 10; n++) {
    term *= -x * x / ((2 * n) * (2 * n - 1));
    sum += term;
  }
  return sum;
};

// Class definition with static members
class Calculus {
  publicField = "public"
  static #privateField = "private";

  constructor(fn) {
    this.fn = fn;
    this.h = EPSILON;
  }

  // Generator function
  *generatePoints(start, end, step) {
    for (let x = start; x <= end; x += step) {
      yield { x, y: this.fn(x) };
    }
  }

  // Arrow function with destructuring
  derivative = (x) => {
    const { h } = this;
    return (this.fn(x + h) - this.fn(x)) / h;
  };

  // Async function with await
  async calculateIntegral(a, b, n = 1000) {
    try {
      const width = (b - a) / n;
      let sum = 0;

      // Promise-based delay
      await new Promise((resolve) => setTimeout(resolve, 100));

      // Array methods and spread operator
      const points = [...Array(n + 1).keys()]
        .map((i) => a + i * width)
        .map((x) => this.fn(x));

      // Reduce with arrow function
      sum = points.reduce((acc, val) => acc + val) * width;

      return sum;
    } catch (error) {
      console.error(`Integration error: ${error?.message ?? "Unknown error"}`);
      throw error;
    }
  }
}

// Template literals and object destructuring
const printResult = ({ x, result }) => {
  console.log(`Result at x=${x}: ${result}`);
};

// Default parameters and rest operator
function compose(f, g, ...rest) {
  return rest.reduce(
    (acc, fn) => (x) => acc(fn(x)),
    (x) => f(g(x))
  );
}

// Async/await with destructuring
const main = async () => {
  // Object literal with method shorthand
  const functions = {
    square(x) {
      return x ** 2;
    },
    cube: (x) => x ** 3,
    get polynomial() {
      return (x) => x ** 2 + 2 * x + 1;
    },
  };

  // Destructuring with renaming
  const { square: f1, cube: f2 } = functions;

  // Map and Set usage
  const derivatives = new Map();
  const uniqueValues = new Set();

  // Optional chaining and nullish coalescing
  const calc = new Calculus(functions?.polynomial ?? f1);

  // Array destructuring and for-of loop
  const points = calc.generatePoints(0, 1, 0.1);
  for (const [index, point] of [...points].entries()) {
    derivatives.set(index, calc.derivative(point.x));
  }

  // Switch statement with numeric literal
  const getOperationName = (code) => {
    switch (code) {
      case 0n:
        return "derivative";
      case 1n:
        return "integral";
      default:
        return "unknown";
    }
  };

  // Try-catch with instanceof
  try {
    const area = await calc.calculateIntegral(0, 1);
    if (area instanceof Number) {
      console.log("Area calculated successfully");
    }
  } catch (error) {
    if (error instanceof Error) {
      console.error(error.message);
    }
  } finally {
    console.log("Calculation complete");
  }
};

// IIFE with async/await
(async () => {
  await main();
})();

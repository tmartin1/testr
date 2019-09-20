# testr

A Simple unit testing utility for R.


## Usage

Import `testr` and the file to be tested into the spec file. Then use the testr methods in the structure shown below to test the imported function.

### Methods

This package exposes the following global methods:

* **`describe`** - Initialize a test suite and for grouping similar tests (like a specific method). Takes two parameters: a string to describe what is being tested, and a callback function, which holds the logic to define any variables needed by the tests and define the specific tests themselves, signified by `it` calls.
* **`it`** - Test a specific method, or a specific part of a method. `it` calls must be inside of a `describe` callback function. Takes two parameters: a string to describe the specific functionality that is being tested, and a callback function, which holds the logic to setup the specific test parameters and execute the condition tests by calling the `expect` function.
* **`expect`** - Defines a specific condition that needs to be met for the test to pass. `expect` calls must be inside of an `it` callback function. You can have more than one `expect` call inside a single `it` callback.

### Example
```R
# SomeFunctions.R
simpleAdd <- function(a, b) { return(a + b) }
simpleSubtract <- function(a, b) { return(a - b) }
simpleDivide <- function(a, b) {
    if (b == 0) {
        throw('Cannot divide by zero')
    } else {
        return(a/b)
    }
}

# SomeFunctions.spec.R
source(file = "testr.R", local = TRUE)
source(file = "SomeFunctions.R", local = TRUE)

describe('simpleAdd', function() {
    it('adds two values', function() {
        result <- simpleAdd(1, 1)

        expect(result)$toEqual(2)

        expect(simpleAdd(1, 2))$toEqual(3)
        expect(simpleAdd(1, 3))$toEqual(4)
    })

    it('adds two other values', function() {
        result <- simpleAdd(1, 1)

        expect(result)$toEqual(2)
    })

    it('failing test example - subtracts two values', function() {
        result <- simpleAdd(1, 1)

        expect(result)$toEqual(0) # This will cause the test to fail.
        expect(simpleAdd(1, 2))$toEqual(3) # Even though this condition passes, the test will fail b/c the first condition failed.
    })
})

describe('simpleSubtract', function() {
    it('adds two values', function() {
        result <- simpleSubtract(1, 1)

        expect(result)$toEqual(0)
    })

    it('failing test example - adds two values', function() {
        result <- simpleSubtract(1, 1)

        expect(result)$toEqual(2)
    })
})

describe('simpleDivide', function() {
    it('divides two values', function() {
        result <- simpleDivide(1, 1)

        expect(result)$toEqual(1)
    })

    it('throws an error when dividing by zero', function() {
        result <- function() { simpleDivide(1, 0) }

        expect(result)$toThrowAnError()
    })
})
```

And the output for the above example would be:
```R
[1] "FAILED - simpleAdd"
[1] "     PASSED - adds two values"
[1] "     PASSED - adds two other values"
[1] "     FAILED - failing test example - subtracts two values"
[1] "          expected 2 to equal 0"

[1] "FAILED - simpleSubtract"
[1] "     PASSED - adds two values"
[1] "     FAILED - failing test example - adds two values"
[1] "          expected 0 to equal 2"

[1] "PASSED - simpleDivide"
[1] "     PASSED - divides two values"
[1] "     PASSED - throws an error when dividing by zero"
```
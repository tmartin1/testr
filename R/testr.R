(function() {
    # #####################################################################################################################
    # Private testr variables and utility methods.
    # #####################################################################################################################

    private <- new.env()
    private$indent <- '    '
    private$describePassing <- FALSE
    private$itPassing <- FALSE
    private$describeScopeActive <- FALSE
    private$itScopeActive <- FALSE
    private$outputBlock <- c()

    # Reset output data.
    private$resetOutput <- function() { private$outputBlock <- c() }

    # Add test result to output data to be printed.
    private$addToOutput <- function(message) {
        private$outputBlock[length(private$outputBlock) + 1] <- message
    }

    # Print output and reset for next test block.
    private$printOutput <- function() {
        outputLines <- length(private$outputBlock)
        print(private$outputBlock[outputLines])

        exceptions <- c()
        for (i in 1:(outputLines - 1)) {
            msg <- private$outputBlock[i]

            if (substr(trimws(msg), 1, 8) == 'expected') {
                exceptions[length(exceptions) + 1] <- msg
            } else {
                print(msg)
            }

            if (substr(trimws(msg), 1, 6) == 'FAILED') {
                for (exception in exceptions) {
                    print(exception)
                }

                exceptions <- c()
            }
        }

        private$outputBlock <- c()
    }

    private$expectCompareBuilder <- function(resultValue) {
        compareHandler <- function(text, test) {
            return(function(compareValue) {
                result <- test(compareValue)

                if (as.logical(result) == FALSE) {
                    private$describePassing <- FALSE
                    private$itPassing <- FALSE

                    private$addToOutput(paste(
                        private$indent,
                        private$indent,
                        'expected',
                        resultValue,
                        text,
                        compareValue
                    ))
                }

                return(as.logical(result))
            })
        }

        compares <- new.env()

        # Geneeral Equivalency Matchers
        compares$toEqual <- compareHandler(
            'to equal',
            function(v2) { return(resultValue == v2) }
        )
        compares$toNotEqual <- compareHandler(
            'to not equal',
            function(v2) { return(resultValue != v2) }
        )

        # Numerical Matchers
        compares$toBeLessThan <- compareHandler(
            'to be less than',
            function(v2) { return(resultValue < v2) }
        )
        compares$toBeLessThanOrEqualTo <- compareHandler(
            'to be less than or equal to',
            function(v2) { return(resultValue <= v2) }
        )
        compares$toBeGreaterThan <- compareHandler(
            'to be greater than',
            function(v2) { return(resultValue > v2) }
        )
        compares$toBeGreaterThanOrEqualTo <- compareHandler(
            'to be greater than or equal to',
            function(v2) { return(resultValue >= v2) }
        )
        # compares$toBeCloseTo <- compareHandler(
        #     'to be close to',
        #     function(v2) { return() }
        # )

        # Boolean Matchers
        compares$toBeTrue <- compareHandler(
            'to be true',
            function() { return(resultValue == TRUE) }
        )
        compares$toBeFalse <- compareHandler(
            'to be false',
            function() { return(resultValue == FALSE) }
        )
        compares$toBeTruthy <- compareHandler(
            'to be truthy',
            function() { return(as.logical(resultValue) == TRUE) }
        )
        compares$toBeFalsy <- compareHandler(
            'to be falsy',
            function() { return(as.logical(resultValue) == FALSE) }
        )

        # Type Matchers
        compares$toBeInstanceOf <- compareHandler(
            'to be an instance of'
            function(v2) { return(is(resultValue, v2)) }
        )

        # List Matchers
        compares$toHaveLength <- compareHandler(
            'to have length'
            function(v2) { return(length(resultValue) == v2) }
        )
        compares$toContain <- compareHandler(
            'to contain'
            function(v2) {
                result <- FALSE

                for(v in list) {
                    if (v == val) { result <- TRUE }
                }

                return(result)
            }
        )

        # Exception Matchers
        compares$toThrowAnError <- compareHandler(
            'to throw an error',
            function(cb) {
                result <- tryCatch(
                    { cb() },
                    error = function(err) { return(TRUE) }
                )

                return(result)
            }
        )
        compares$toThrowAWarning <- compareHandler(
            'to throw an warning',
            function(cb) {
                result <- tryCatch(
                    { cb() },
                    warning = function(war) { return(TRUE) },
                )

                return(result == TRUE)
            }
        )

        return(compares)
    }


    # #####################################################################################################################
    # Exposed testing methods.
    # #####################################################################################################################

    # Describe block for grouping similar tests.
    # @param [String] description - Short description, like the name of the file or name of the function being tested.
    # @param [Function] cb - Callback function that holds the methods to test specific aspecs of the described entity.
    describe <<- function(description, cb) {
        private$describePassing <- TRUE
        private$describeScopeActive <- TRUE

        cb()

        if (private$describePassing == TRUE) {
            private$addToOutput(paste('PASSED -', description))
        } else {
            private$addToOutput(paste('FAILED -', description))
        }

        private$printOutput()
        private$describeScopeActive <- FALSE
    }

    # Function for executing a specific test inside of a 'describe' block.
    # @param [String] description - Short description about what specific functionality is being tested.
    # @param [Function] cb - Callback function that returns a boolean signifying if the test passed or not.
    # it MUST be called inside of a 'describe' callback function or the tests will not execute properly.
    it <<- function(description, cb) {
        if (private$describeScopeActive == FALSE) {
            throw('it test calls must be placed inside of a describe block.')
        }

        private$itPassing <- TRUE
        private$itScopeActive <- TRUE

        cb()

        if (private$itPassing == TRUE) {
            private$addToOutput(paste(private$indent, 'PASSED -', description))
        } else {
            private$addToOutput(paste(private$indent, 'FAILED -', description))
        }

        private$itScopeActive <- FALSE
    }

    # Detail a specific condition to compare within an 'it' block. Can have multiple 'expect' statements inside one 'it' block.
    # expect MUST be called inside of an 'it' callback function or the tests will not execute properly.
    expect <<- function(value) {
        if (private$itScopeActive == FALSE) {
            throw('expect test calls must be placed inside of a describe block.')
        }

        return(private$expectCompareBuilder(value))
    }
})()

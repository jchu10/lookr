lookr
=====

`lookr` will provide a set of tools for analyzing looking-while-listening eyetracking experiments performed by the [Learning to Talk](http://learningtotalk.org/) project. 

## Tasks
- [ ] `Session` calls `%@%`. Document and add attributes.r to repo.
- Testing: 
    - [ ] does the `Session` function work for the deidentified test-data? Might need to adjust regexes then test Session on each test session.
- [ ] develop tests for `Stimdata`
- [ ] document the experiments in `/inst/test/data`
- [ ] include Pat Reidy's original "beta" version scripts under `inst`


### References
Core references on the looking-while-listening experiment paradigm, as used by the Learning to Talk project, are listed below.

* Fernald, A., Zangl, R., Portillo, A. L., & Marchman, V. A. (2008). __Looking while listening: Using eye movements to monitor spoken language comprehension by infants and young children.__ In I. A. Sekerina, E. M. Fernández, & H. Clahsen (Eds.), _Developmental Psycholinguistics: On-line methods in children's language processing_ (pp. 97--135). Retrieved from http://psych.stanford.edu/~babylab/pdfs/LWL.2008.pdf
* Barr, D. J. (2008). __Analyzing "visual world" eyetracking data using multilevel logistic regression.__ _Journal of Memory and Language_, _59_(4), 457--474. `doi:10.1016/j.jml.2007.09.002`

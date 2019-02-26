## Terms
: <dfn>candidate feature</dfn>
:: A feature included in the IOP for which no or not sufficient test and conformance tool exist. Candidate technologies may be removed when publishing the next major version of this specification. 

## Conventions ## {#conventions}
### Background
DASH-IF provides and documents guidelines for implementers to refer to interoperability descriptions. In doing so, the DASH-IF agreed to use key words in order to support readers of the DASH-IF documents to understand better how to interpret the language. The usage of key words in this document is provided below.
### Key Words
The key word usage is aligned with the definitions in [[!rfc2119]], namely:
* SHALL:   This word means that the definition is an absolute requirement of the specification.
* SHALL NOT:   This phrase means that the definition is an absolute prohibition of the specification.
* SHOULD: This word means that there may exist valid reasons in particular circumstances to ignore a particular item, but the full implications must be understood and carefully weighed before choosing a different course. 
* SHOULD NOT:   This phrase means that there may exist valid reasons in particular circumstances when the particular behavior is acceptable or even useful, but the full implications should be understood and the case carefully weighed before implementing any behavior described with this label.
* MAY:   This word means that an item is truly optional.  One vendor may choose to include the item because a particular marketplace requires it or because the vendor feels that it enhances the product while another vendor may omit the same item. 
These key words are attempted to be used consistently in this document, but only in small letters. 
### Mapping to DASH-IF Assets
If an IOP document associates such a key word from above to a content authoring statement then the following applies with respect to DASH-IF assets:
* SHALL: The conformance software provides a conformance check for this and issues an error if the conformance is not fulfilled. The author of the requirement is expected to be aware of the consequences for the conformance software.
* SHALL NOT: The conformance software provides a conformance check for this and issues an error if the conformance is not fulfilled. The author of the requirement is expected to be aware of the consequences for the conformance software.
* SHOULD: The conformance software provides a conformance check for this and issues a warning if the conformance is not fulfilled. The author of the recommendation is expected to be aware of the consequences for the conformance software.
* SHOULD NOT: The conformance software provides a conformance check for this and issues a warning if the conformance is not fulfilled. The author of the recommendation is expected to be aware of the consequences for the conformance software.
* SHOULD and MAY: If present, the feature check of the conformance software documents a feature of the content.
If an IOP document associates such a key word from above to a DASH Client then the following applies:
* SHALL/SHALL NOT: Test content is necessarily provided with this rule and the reference client implements the feature. The author of the requirement is expected to be aware of the consequences for both, providing test content and implementation support in the reference client.
* SHOULD/SHOULD NOT: Test content is provided with this rule and the reference client implements the feature unless there is a justification for not implementing this. The author of the requirement is expected to be aware of the consequences for both, providing test content and implementation support in the reference client.
* MAY: Test content is provided and the reference client implements the feature if there is a justification this.
Note that features included in this document and for which no test and conformance material is provided according to the above rules are only published as a [=candidate features=], and may be removed if no test material is provided before releasing a new version of this specification. For the availability of test material, please check the [DASH-IF web page](http://www.dashif.org).

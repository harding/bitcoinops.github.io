---
title: Cross-input signature aggregation (CISA)

## Optional.  Shorter name to use for reference style links e.g., "foo"
## will allow using the link [topic foo][].  Not case sensitive
shortname: cisa

## Optional.  An entry will be added to the topics index for each alias
aliases:
  - Half aggregation of signatures
  - Full aggregation of signatures

## Required.  At least one category to which this topic belongs.  See
## schema for options
categories:
  - Scripts and Addresses
  - Soft Forks

## Optional.  Produces a Markdown link with either "[title][]" or
## "[title](link)"
primary_sources:
    - title: "Cross-input signature aggregation research repository"
      link: https://github.com/BlockstreamResearch/cross-input-aggregation

    - title: Half-Aggregation of BIP 340 signatures
      link: https://github.com/BlockstreamResearch/cross-input-aggregation/blob/master/half-aggregation.mediawiki

## Optional.  Each entry requires "title" and "url".  May also use "feature:
## true" to bold entry and "date"
optech_mentions:
  - title: "Taproot to not include cross-input signature aggregation"
    url: /en/newsletters/2019/05/14/#no-cross-input-signature-aggregation

  - title: "Question: why does signature aggregation interefer with signature adaptors?"
    url: /en/newsletters/2021/06/30/#why-does-blockwide-signature-aggregation-prevent-adaptor-signatures

  - title: Draft BIP about half aggregation of BIP340 schnorr signatures
    url: /en/newsletters/2022/07/13/#half-aggregation-of-bip340-signatures

## Optional.  Same format as "primary_sources" above
see_also:
  - title: Schnorr signatures
    link: topic schnorr signatures

  - title: BLS signatures
    link: topic bls signatures

  - title: Signature adaptors
    link: topic adaptor signatures

  - title: Scriptless multisignatures
    link: topic multisignature

  - title: Signer delegation
    link: topic signer delegation

## Optional.  Force the display (true) or non-display (false) of stub
## topic notice.  Default is to display if the page.content is below a
## threshold word count
#stub: false

## Required.  Use Markdown formatting.  Only one paragraph.  No links allowed.
## Should be less than 500 characters
excerpt: >
  **Cross-input signature aggregation (CISA)** is a proposal to reduce
  the number of signatures a transaction requires, which would require a
  consensus change.  In theory, every signature required to make a
  transaction valid could be combined into a single signature that
  covers the whole transaction.

---
There are two forms of CISA that are compatible with Bitcoin's secp256k1
curve parameters:

- **Full aggregation** involves the signers of different inputs in a
  transaction cooperating interactively to create a single signature for
  the entire transaction.  The aggregated signature would be the same
  size as a regular signature, e.g. 64 bytes (16 vbytes) for a
  [BIP341][]-style [schnorr signature][topic schnorr signatures].

- **Half aggregation** involves the signers of different inputs in a
  transaction producing a valid transaction in the normal way.  Notably,
  they don't need to cooperate interactively and can instead coordinate
  non-interactively using scripted multisignatures, sighash flags, or
  other features.  Once a valid transaction has been produced, any one
  can convert all valid BIP340-style signatures in the transaction into
  a single half-aggregated signature.  For a transaction with _n_
  signatures, the size of the half-aggregated signature would be `32n +
  32` bytes (`8n + 8` vbytes).

For a transaction that has an equal number of inputs and outputs, such
as the simplest type of [coinjoin][topic coinjoin] transaction, the
maximum space savings of full aggregation is around 15%.  For
half aggregation, it's about half that.  The savings is less for
transactions with fewer inputs.

![Plot of transaction size savings for full-agg and half-agg vs unaggregated transactions](/img/posts/2024-01-agg-savings.png)

A transaction without aggregation allows every signature to commit to a
[signature adaptor][topic adaptor signatures].  A transaction with full
aggregation may only have one signature adaptor for the entire
transaction---and every signing party must agree to the same commitment.
A transaction with half aggregation cannot contain any signature
adaptors.

Full aggregation must be carefully designed to avoid problems such as
key and nonce cancellation attacks which could allow an adversary to
steal funds.  The standard protections against cancellation attacks that
are implemented in [scriptless multisignature protocols][topic
multisignature] like [MuSig2][topic musig] may not be available in
certain soft fork proposals for [signer delegation][topic signer
delegation], meaning full aggregation needs to be carefully evaluated
for possible dangerous interactions.  Half aggregation may not produce
as many potentially harmful interactions, leading some proponents to
[claim][halfagg doc] that "the difference in complexity between
half-aggregation and full aggregation is so significant that basing a
CISA on half-aggregation is a legitimate approach." <!-- TODO:I'm
writing beyond my expertise here; please feel free to open a PR with
more details -harding -->

Either type of aggregation can be added in a soft fork that adds a new
signature verification method, such as by using a new witness version.
It would also be possible for a soft fork to enable non-interactive full
aggregation in conjunction with different curve parameters for Bitcoin,
such as in the [BLS signature scheme][topic bls signatures].

{% include references.md %}
{% include linkers/issues.md issues="" %}
[halfagg doc]: https://github.com/BlockstreamResearch/cross-input-aggregation/blob/master/half-aggregation.mediawiki

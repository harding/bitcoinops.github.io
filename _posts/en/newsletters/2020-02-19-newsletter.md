---
title: 'Bitcoin Optech Newsletter #85'
permalink: /en/newsletters/2020/02/19/
name: 2020-02-19-newsletter
slug: 2020-02-19-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter requests help testing release candidates for
Bitcoin Core and C-Lightning, summarizes a discussion about taproot
versus implementing MAST and schnorr separately, describes new ideas for
using PoDLEs in LN channel construction, and highlights a new
implication of work on privacy-enhanced payments to unannounced LN
nodes.  Also included are our regular sections about notable changes to
popular services, client software, and infrastructure projects

## Action items

- **Help test Bitcoin Core 0.19.1rc2:** this upcoming maintenance
  [release][bitcoin core 0.19.1] includes several bug fixes.
  Experienced users are encouraged to help test for any regressions or
  other unexpected behavior.

- **Help test C-Lightning 0.8.1rc3:** this [Release Candidate][cl 0.8.1] (RC) adds
  several new features (including those described in the *notable
  changes* section below) and provides multiple bug fixes.  Experienced
  users are encouraged to help test the RC.

FIXME:check for latest RCs / releases shortly before publication

## News

- **Discussion about taproot versus alternatives:** a group of
  developers who prefers to remain anonymous (so we'll call them Anon)
  wrote a [criticism][anon reflowed] of taproot in comparison to
  alternative approaches for enabling [MAST][topic mast] and [schnorr
  signatures][topic schnorr signatures] in Bitcoin.  Anon concludes
  their criticism with five questions which we use below to organize our
  summary of Anon's concerns and the replies posted by several Bitcoin
  contributors.

    1. {:#tap1} Anon asks, "Is Taproot actually more private than bare
       MAST and schnorr separately?  What are the actual anonymity set
       benefits compared to doing them separately?"

       Anthony Towns [replies][towns tap], "Yes [it is more private],
       presuming single-pubkey-single-signature remains a common
       authorization pattern."  Towns shows that single-sig spends
       currently represent more than 57% of all transaction outputs (and
       possibly much more, given the frequent use of P2SH-wrapped
       P2WPKH).   Either with or without taproot, schnorr will allow
       extending the set of single-sig spends to cases possible to
       accomplish with interactive multisig (e.g.  n-of-n), interactive
       threshold signing (e.g. k-of-n), or adaptor signatures.  Yet only
       with taproot can the anonymity set also practically extend to
       cases where spenders prefer to use single-sig but want the option
       to fall back to using scripts if they can't generate the necessary
       single signature.  If MAST and schnorr were to be done separately,
       single-sig users would need to pay more to spend a UTXO than they
       do now, and so it's unlikely many of them would join the
       anonymity set that covers users of fallback scripts.

    2. {:#tap2} Anon asks, "Is Taproot actually cheaper than bare MAST and
       schnorr separately?"  Earlier in the email, Anon claimed that
       taproot saves 67 bytes compared to MAST+schnorr for key-path
       spending but adds 67 bytes for script-path spending.

       Towns points out a redundant data field in Anon's calculation and
       shows that taproot actually only adds about 33 bytes in the
       script-path spending case, making the cost-benefit analysis
       asymmetric in favor of taproot.  David Harding [notes][harding
       tap] that the extra cost (which translates to 8.25 vbytes) is
       quite small compared to all the other data a script-path spender
       would need to provide to spend a UTXO (e.g. 41 vbytes of input
       data, 16-vbyte signatures or other witnesses of various sizes,
       one or more 8-vbyte merkle nodes, and the script to execute).

    3. {:#tap3} Anon asks, "Is Taproot riskier than bare MAST and
       schnorr separately given the new crypto?"

       Towns replies that he "doesn't think so; most of the risk for
       either of those is in getting the details right. [...] Most of
       the complicated crypto parts are at the application layer:
       [MuSig][topic musig], threshold signatures, adaptor signatures,
       scriptless scripts, etc."  He also links several resources for
       those wanting to learn more ([1][taplearn1], [2][taplearn2],
       [3][taplearn3]).

    4. {:#tap4} Anon asks, "couldn't we forego the [Nothing Up My
       Sleeve] [NUMS][] point requirement and be able to check if it's a
       hash root directly?"  This is a requirement that wallets create
       and later publish a taproot internal key even if it's just a
       random curve point because they never intended to use a key-path
       spend.  Anon essentially proposes allowing the spender to skip
       publishing an internal key and go straight to script-path
       verification.

       Towns replies, "That would decrease the anonymity set by a lot."
       The reason is that a non-present internal key would reveal at
       spend time that the spender never had any intention of using a
       key-path spend, distinguishing their spends from other spends
       where using a key-path was an option.  Towns further notes that
       not publishing an internal key would only save 8 vbytes.

       Jonas Nick and Jeremy Rubin each provide their own analysis.
       Nick [concludes][nick tap] that "[because] anonymity sets in
       Bitcoin are permanent and software tends to be deployed longer
       than anyone would expect [...] realistically taproot is superior
       to [Anon's proposed] optimization."  Rubin [concludes][rubin tap]
       the opposite, favoring either Anon's proposal or Rubin's own
       proposed alternative (which would still result in the same
       privacy loss).

    5. {:#tap5} Anon asks, "Is the development model of trying to jam a
       bunch of features into Bitcoin all at once good for Bitcoin
       development?"

       Towns replies that "bundling these particular changes together
       [gives] the advantages of taproot"---the flexibility to use either
       key-path or script-path spending, that "key-path comes at no cost
       compared to not using taproot", that "adding a script-path comes
       at no cost if you don't end up using it," and that "if you can
       interactively verify the script conditions off-chain, you can
       always use the key path".

    The discussion did not reach an obvious conclusion.  If there are
    any additional notable developments, we'll report on them in a
    future newsletter.

- **Using PoDLE in LN:** as described in [Newsletter #83][news83
  interactive], LN developers are working to specify a protocol for the
  interactive construction of funding transactions as a step towards
  dual-funded payment channels and [channel splicing][topic splicing].
  One problem for dual-funded channel setup is that someone can propose
  opening a channel with you, learn one or more of your UTXOs, and then
  abandon the channel setup process before signing a transaction and
  paying any fees.  A proposed solution to this problem is to require
  channel open proposals contain a Proof of Discrete Logarithm Equivalence
  ([PoDLE][]) which JoinMarket uses to avoid the same type of
  costless UTXO disclosure attacks.

    This week, Lisa Neigut published her [analysis][neigut podle1] of
    the PoDLE idea for interactive funding.  She also separately
    [described][neigut podle2] an attack where dishonest Mallory waits
    for honest Alice to submit a PoDLE and then uses that to get other
    nodes to blacklist Alice.  Neigut proposed a mitigation but an
    alternative more compact mitigation was [proposed][gibson podle] by
    JoinMarket developer Adam Gibson.  Gibson's approach requires the
    PoDLE commit to the node that's expected to receive it, preventing
    it from being maliciously reused with other nodes.  Gibson also
    described some of the design decisions that went into
    JoinMarket's use of PoDLE and suggested how LN developers might want
    to use different tradeoffs for LN's own unique constraints.

- **Decoy nodes and lightweight rendez-vous routing:** Bastien
  Teinturier previously [posted][teinturier delink] about breaking the
  link between what data is included in a [BOLT11][] invoice and the
  funding transaction of the channel that will receive the payment (see
  [Newsletter #82][news82 unannounced]).  After further discussion and
  refinement, Teinturier [noted][teinturier rv] a side effect of his
  scheme might enable convenient rendez-vous routing---privacy-enhanced
  payment routing where neither the receiving node nor the spending node
  learns anything about each other's network identity.  See
  [Teinturier's documentation][rv gist] for the scheme or read about
  previous discussion of rendez-vous routing in [Newsletter #22][news22
  rv].

## Changes to services and client software

*In this monthly feature, we highlight interesting updates to Bitcoin
wallets and services.*

FIXME:bitschmidty

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo],
[C-Lightning][c-lightning repo], [Eclair][eclair repo], [LND][lnd repo],
[libsecp256k1][libsecp256k1 repo], [Bitcoin Improvement Proposals
(BIPs)][bips repo], and [Lightning BOLTs][bolts repo].*

- [Bitcoin Core #18104][] ends support for building 32-bit x86 binaries
  for Linux as part of the Bitcoin Core release process.  The
  corresponding 32-bit binaries for Windows were previously removed
  several months ago (see [Newsletter #46][news46 win32]).  The 32-bit
  Linux binaries are still built as part of Bitcoin Core's continuous
  integration tests and users may still build them manually, but the
  binaries are no longer being distributed by the project due to a
  lack of use and hands-on developer testing.

- [C-Lightning #3488][] standardizes C-Lightning’s requests for Bitcoin data
  making it possible to run C-Lightning on something other than Bitcoin Core
  as the backend. This pull-request is part of a larger project to allow more
  freedom for how C-Lightning interacts with the Bitcoin backend as proposed
  in [C-Lightning #3354][]. Keeping the backend interactions general and
  unassuming allows for plugins to either make standard RPC calls, combine
  RPCs into more abstract methods, or even create notifications. While
  bitcoind interaction through bitcoin-cli remains the default, this project
  works towards opening up possibilities for mobile integration (see
  [C-Lightning #3484][]) or allowing users to share a full-node like an
  [esplora][esplora] instance for those that might only go
  [online infrequently for channel management and monitoring][remyers twitter].

- [C-Lightning #3500][] implements a simple solution to a problem that
  could cause channels to become stuck with neither party able to send
  funds to the other.  The [stuck funds problem][bolts #728] occurs when
  a payment would cause the party who funded the channel to become
  responsible for paying more value than their current balance.  For
  example, Alice funds a channel and pays Bob her full available
  balance. Alice now can't spend any more money (as expected) but Bob
  also can't pay Alice because that would require increasing the size of
  the commitment transaction and its corresponding fees---fees that the
  funder (Alice) is responsible for paying.  This renders the channel
  unusable in both directions.  C-Lightning's merge simply restricts the
  user, when they're the funder, from spending all of their available
  balance, providing an effective short term fix.  An alternative
  solution is proposed in [C-Lightning #3501][], but it's waiting on the
  outcome of further discussion between the maintainers of all LN
  implementations.

- [C-Lightning #3489][] allows multiple plugins to attach to the
  `htlc_accepted` plugin hook, with plans to allow multiple plugin
  attachments to other hooks in the future.  For the `htlc_accepted`
  hook, this allows a plugin to either reject the HTLC, resolve the HTLC
  (i.e. claim any payment by returning the preimage), or pass the HTLC
  on to the next plugin bound to the hook.

- [C-Lightning #3477][] allows plugins to register feature flags that
  will be sent in the node's [BOLT1][bolt1 init] `init` message, the [BOLT7][bolt7 node announce]
  `node_announcement` message, or the [BOLT11][bolt11 featurebits] invoice's feature bits
  field (field `9`).  This allows a plugin to signal to other programs
  that its node can handle the advertised features.

- [Libsecp256k1 #682][] removes the Java Native Interface (JNI) bindings
  with the reason, "[the] JNI bindings would need way more work to
  remain useful to Java developers but the maintainers and regular
  contributors of libsecp are not very familiar with Java."  The PR
  notes that ACINQ is known to use the bindings in their projects and
  maintains their own [fork][acinq libsecp] of the library.

{% include references.md %}
{% include linkers/issues.md issues="18104,3488,3354,3484,3500,3489,3477,682,728,3501" %}
[bitcoin core 0.19.1]: https://bitcoincore.org/bin/bitcoin-core-0.19.1/
[cl 0.8.1]: https://github.com/ElementsProject/lightning/releases/tag/v0.8.1rc3
[news83 interactive]: /en/newsletters/2020/02/05/#interactive-construction-of-ln-funding-transactions
[podle]: /en/newsletters/2020/02/05/#podle
[news82 unannounced]: /en/newsletters/2020/01/29/#breaking-the-link-between-utxos-and-unannounced-channels
[news22 rv]: /en/newsletters/2018/11/20/#hidden-destinations
[news46 win32]: /en/newsletters/2019/05/14/#bitcoin-core-15939
[anon reflowed]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-February/017618.html
[towns tap]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-February/017622.html
[harding tap]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-February/017621.html
[taplearn1]: https://github.com/bitcoin-core/secp256k1/pull/558
[taplearn2]: https://github.com/apoelstra/taproot
[taplearn3]: https://github.com/ajtowns/taproot-review
[nick tap]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-February/017625.html
[rubin tap]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-February/017629.html
[neigut podle1]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2020-February/002516.html
[neigut podle2]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2020-February/002517.html
[gibson podle]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2020-February/002522.html
[teinturier delink]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2020-January/002435.html
[teinturier rv]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2020-February/002519.html
[rv gist]: https://gist.github.com/t-bast/9972bfe9523bb18395bdedb8dc691faf
[acinq libsecp]: https://github.com/ACINQ/secp256k1/tree/jni-embed/src/java
[bolt1 init]: https://github.com/lightningnetwork/lightning-rfc/blob/master/01-messaging.md#the-init-message
[bolt7 node announce]: https://github.com/lightningnetwork/lightning-rfc/blob/master/07-routing-gossip.md#the-node_announcement-message
[bolt11 featurebits]: https://github.com/lightningnetwork/lightning-rfc/blob/master/11-payment-encoding.md#feature-bits
[nums]: https://en.wikipedia.org/wiki/Nothing-up-my-sleeve_number
[esplora]: https://github.com/blockstream/esplora
[remyers twitter]: https://twitter.com/remyers_/status/1226838752267468800

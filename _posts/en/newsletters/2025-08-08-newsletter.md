---
title: 'Bitcoin Optech Newsletter #366'
permalink: /en/newsletters/2025/08/08/
name: 2025-08-08-newsletter
slug: 2025-08-08-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter FIXME

## News

- **Continued discussion about lowering the minimum relay feerate:**
  Gloria Zhao [posted][zhao minfee] to Delving Bitcoin about lowering
  the [default minimum relay feerate][topic default minimum transaction
  relay feerates] by 90% to 0.1 sat/vbyte.  She encouraged conceptual
  discussion about the idea and how it might affect other software.  For
  concerns specific to Bitcoin Core, she linked to a [pull
  request][bitcoin core #33106].

- **Peer block template sharing to mitigate problems with divergent mempool policies:**
  Anthony Towns [posted][towns tempshare] to Delving Bitcoin to suggest
  full node peers occasionally send each other their current template
  for the next block using [compact block relay][topic compact block
  relay] encoding.  The receiving peer could then request any
  transactions from the template that it was missing, either adding them
  to the local mempool or storing them in a cache.  This would allow
  peers with divergent mempool policies to share transactions despite
  their differences and provides an alternative to the previous proposal
  of using _weak blocks_ instead (see [Newsletter #299][news299 weak
  blocks]).  Towns provided a [proof of concept implementation][towns
  tempshare poc].

## Bitcoin Core PR Review Club

*In this monthly section, we summarize a recent [Bitcoin Core PR Review
Club][] meeting, highlighting some of the important questions and
answers.  Click on a question below to see a summary of the answer from
the meeting.*

FIXME:stickies-v

{% include functions/details-list.md
  q0="FIXME"
  a0="FIXME"
  a0link="https://bitcoincore.reviews/31829#l-12FIXME"
%}

## Optech recommends

[Bitcoin++ Insider][] has begun publishing reader-funded news about
technical Bitcoin topics.  Two of their free weekly newsletters, _Last
Week in Bitcoin_ and _This Week in Bitcoin Core_, may be especially
interesting to regular readers of the Optech newsletter.

## Releases and release candidates

_New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates._

- [Bitcoin Core 29.1rc1][] is a release candidate for a maintenance
  version of the predominant full node software.

- BTCPay Server 2.2.0 FIXME:harding

## Notable code and documentation changes

_Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo], and [BINANAs][binana repo]._

- [Bitcoin Core #32941][] p2p: TxOrphanage revamp cleanups

- [Bitcoin Core #31385][] package validation: relax the package-not-child-with-unconfirmed-parents rule

- [Bitcoin Core #31244][] descriptors: MuSig2

- [Bitcoin Core #30635][] rpc: add optional blockhash to waitfornewblock, unhide wait methods in help

- [Bitcoin Core #28944][] wallet, rpc: add anti-fee-sniping to `send` and `sendall`

- [Eclair #3133][] Add outgoing reputation

- [LND #10097][] Roasbeef/gossip-block-fix

- [LND #9625][] Add deletecanceledinvoice RPC call

- [Rust Bitcoin #4730][] p2p: Add formal `Alert` type

- [BLIPs #55][] Webhook Registration (LSPS5) (#55)

## Correction

In [last week's newsletter][news365 p2qrh], we incorrectly described the
updated version of [BIP360][], _pay to quantum-resistant hash_, as
"making exactly the change" that Tim Ruffing showed was secure in his
recent paper.  What BIP360 actually does is replaces the elliptical
curve commitment to a SHA256-based merkle root (plus a keypath
alternative) with the merkle root directly.  Ruffing's paper showed that
taproot, as currently used, is secure if a quantum-resistant signature
scheme were added to the [tapscript][topic tapscript] language and
keypath spends were disabled.  BIP360 instead requires wallets upgrade
to a variant on taproot (albeit, a trivial variant), eliminates the
keypath mechanism from its variant, and describes the addition of a
quantum-resistant signature scheme to the scripting language used in its
tapleaves.

We apologize for the error and thank Tim Ruffing for notifying us about
our mistake.

{% include snippets/recap-ad.md when="2025-08-12 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="33106,32941,31385,31244,30635,28944,3133,10097,9625,4730,55" %}
[bitcoin core 29.1rc1]: https://bitcoincore.org/bin/bitcoin-core-29.1/
[bitcoin++ insider]: https://insider.btcpp.dev/
[news365 p2qrh]: /en/newsletters/2025/08/01/#security-against-quantum-computers-with-taproot-as-a-commitment-scheme
[zhao minfee]: https://delvingbitcoin.org/t/changing-the-minimum-relay-feerate/1886/
[towns tempshare]: https://delvingbitcoin.org/t/sharing-block-templates/1906
[towns tempshare poc]: https://github.com/ajtowns/bitcoin/commit/ee12518a4a5e8932175ee57c8f1ad116f675d089
[news299 weak blocks]: /en/newsletters/2024/04/24/#weak-blocks-proof-of-concept-implementation

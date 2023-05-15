---
title: 'Bitcoin Optech Newsletter #251'
permalink: /en/newsletters/2023/05/17/
name: 2023-05-17-newsletter
slug: 2023-05-17-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter FIXME:harding

## News

- **Testing HTLC endorsement:** several weeks ago, Carla Kirk-Cohen and
  Clara Shikhelman [posted][] to the Lightning-Dev mailing list about
  the next steps she and others planned to take to test the idea of
  [HTLC][topic htlc] endorsement (see [Newsletter #239][news239
  endorsement]) as part of a mitigation for [channel jamming
  attacks][topic channel jamming attacks].  Most notably, they provided a
  short [proposed specification][bolts #1071] that could be deployed
  using an experimental flag, preventing it from having any effect on
  interactions with non-participating nodes.

    Once deployed by experimenters, it should become easier to answer
    one of the [constructive criticisms][] of this idea, which is how
    many payments originate from spenders who frequently use the same
    peers and roughly the same routes.  If the core users of LN are
    frequently sending payments to each other over many of the same
    routes, and if the reputation system works as planned, then that
    core network will be more likely to keep functioning during a
    channel jamming attack.  But if most spenders only send payments
    rarely (or only send their most critical types of payments rarely,
    such as high-value payments), then they won't have enough
    interactions to build a reputation, or the reputation data will lag
    far behind the current state of the network (making it less useful
    or even allowing reputation to be abused).

- **Request for feedback on proposed specifications for LSPs:** Severin
  Bühler [posted][] to the Lightning-Dev mailing list a request for
  feedback on two specifications for interoperability between Lightning
  Service Providers (LSPs) and their clients (usually non-forwarding LN
  nodes).  The first specification describes an API for allowing a
  client to purchase a channel from an LSP.  The second describes an API
  for setting up and managing Just-In-Time (JIT) channels, which are
  channels that start their lives as virtual payment channels; when the
  first payment to the virtual channel is received, the LSP broadcasts a
  transaction that will anchor the channel onchain when it is confirmed
  (making it into a regular channel).

    In a [reply][], developer ZmnSCPxj wrote in favor of open specifications
    for LSPs.  He noted that they make it easy for a client to connect
    to multiple LSPs, which will prevent vendor lock-in and improve
    privacy.

- **Challenges with zero-conf channels when dual funding:** Bastien
  Teinturier [posted][] to the Lightning-Dev mailing list about the
  challenges of allowing [zero-conf channels][] when using the
  [dual-funding protocol][].   Zero-conf channels can be used even the
  channel open transaction is confirmed; this is trustless in some
  cases.  Dual-funded channels are channels that were created using the
  dual-funding protocol, which may include channels where the open
  transaction contains inputs from both parties in the channel.

    Zero-conf is only trustless when one party controls all of the
    inputs to the open transaction.  For example, Alice creates the
    open transaction, gives Bob some funds in the channel, and Bob tries
    spending those funds through Alice to Carol.  Alice can safely forward
    the payment to Carol because Alice knows she's in control of the
    open transaction eventually becoming confirmed.  But if Bob also has
    an input in the open transaction, he can get a conflicting
    transaction confirmed that will prevent the open transaction from
    confirming---preventing Alice from being compensated for any money
    she forwarded to Carol.

    Several ideas for allowing zero-conf channel opens with dual funding
    were discussed, although none seemed satisfying to participants as
    of this writing.

- **Advanced payjoin applications:** Dan Gould [posted][] to the
  Bitcoin-Dev mailing list several suggestions for using the
  [payjoin][topic payjoin] protocol to do more than just send or receive
  a simple payment.  Two of the suggestions we found most interesting
  were versions of [transaction cut-through][], an old idea for
  improving privacy, improving scalability, and reducing fee costs:

    - *Payment forwarding:* rather than Alice paying Bob, Alice instead
      pays Bob's vendor Carol, reducing a debt he owes her (or
      pre-paying for an expected future bill).

    - *Batched payment forwarding:* rather than Alice paying Bob, Alice
      instead pays several people Bob owes money (or wants to establish
      a credit with).  Gould example considers an exchange which has a
      steady stream of deposits and withdrawals; payjoin allows withdrawals
      to be paid for by new deposits when possible.

    Both of these techniques allow reducing what would be at least two
    transactions into a single transaction, saving a considerable amount
    of block space.  When [batching][topic payment batching] is used,
    the space savings may be even larger.  Even better from the
    perspective of the original receiver (e.g. Bob), he may be able to
    get the original spender (e.g. Alice) to pay all or some of the
    fees.  Beyond the space and fee savings, removing transactions from
    the block chain and combining operations like receiving and spending
    makes it significantly more difficult for block chain surveillance
    organizations to reliably trace the flow of funds.

    As of this writing, the post had not received any discussion on the
    mailing list.

- **Summaries of Bitcoin Core developers in-person meeting:** several
  developers working on Bitcoin Core recently met to discuss aspects of
  the project.  Notes from several discussions during that meeting have
  been [published][].  Topics discussed included [fuzz testing][], an
  [assumeUTXO][], [ASMap][], [silent payments][], [libbitcoinkernel][],
  [refactoring (or not)][], and [package relay][].  Also discussed were
  two other topics we think deserve special attention:


    - [Mempool clustering][] summarizes a suggestion for a significant
      redesign of how transactions and their metadata are stored in
      Bitcoin Core's mempool.  The notes describe a number of problems
      with the current design, provide an overview of the new design,
      and suggest some of the challenges and tradeoffs involved.  The
      summary mentions slides or other material which is not available,
      and there's no written summary that we're available of, so we're
      unable to provide a more detailed description at this time, but
      anyone interested in the topic may want to read the summary.

    - [Project meta discussion][] summarizes a varied discussion about
      the projects goals and how to achieve them despite many
      challenges, both internal and external.  Some of the discussion
      has already led to experimental changes in the project's
      management, such as a more project-focused approach for the next
      major release after version 25.

## FIXME:title_for_limited_series #1: why do we have a mempool?

_The first segment in a ten-part weekly series about transaction relay,
mempool inclusion, and mining transaction selection---including why
Bitcoin Core has a more restrictive policy than allowed by consensus and
wallets can most effectively use that policy._

{% include specials/policy/en/01-why-mempool.md %}

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

<!-- FIXME:harding to update Tuesday -->

- [Core Lightning 23.05rc2][] is a release candidate for the next
  version of this LN implementation.

- [Bitcoin Core 24.1rc2][] is a release candidate for a maintenance
  release of the current version of Bitcoin Core.

- [Bitcoin Core 25.0rc1][] is a release candidate for the next major
  version of Bitcoin Core.

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo], and
[Bitcoin Inquisition][bitcoin inquisition repo].*

- [Bitcoin Core #26076][] RPC methods that show derivation paths for
  public keys now use `h` instead of a single-quote `'` to indicate a
  hardened derivation step. Note that this changes the descriptor
  checksum. When handling descriptors with private keys, the same symbol
  is used as when the descriptor was generated or imported. For legacy
  wallets the `hdkeypath` field in `getaddressinfo` and the
  serialization format of wallet dumps remain unchanged.

- [Bitcoin Core #27608][] p2p: Avoid prematurely clearing download state for other peers FIXME:harding

- [LDK #2286][] Create and Sign PSBTs for spendable outputs FIXME:harding

- [LDK #1794][] dunxen/2022-10-dualfunding-act-1 FIXME:harding

- [Libsecp256k1 #1066][] Abstract out and merge all the magnitude/normalized logic FIXME:harding

- [Libsecp256k1 #1299][] Infinity handling: ecmult_const(infinity) works, and group verification FIXME:harding

- [Rust Bitcoin #1844][] make bip21 schema lowercase FIXME:harding

- [Rust Bitcoin #1837][] feat: generate PrivateKey FIXME:harding

- [BOLTs #1075][] t-bast/remove-disconnect-warning FIXME:harding

{% include references.md %}
{% include linkers/issues.md v=2 issues="26076,27608,2286,1794,1066,1299,1844,1837,1075" %}
[Core Lightning 23.05rc2]: https://github.com/ElementsProject/lightning/releases/tag/v23.05rc2
[bitcoin core 24.1rc2]: https://bitcoincore.org/bin/bitcoin-core-24.1/
[bitcoin core 25.0rc1]: https://bitcoincore.org/bin/bitcoin-core-25.0/
[news239 endorsement]: /en/newsletters/2023/02/22/#feedback-requested-on-ln-good-neighbor-scoring
[fuzz testing]: https://btctranscripts.com/bitcoin-core-dev-tech/2023-04-27-fuzzing/
[assumeutxo]: https://btctranscripts.com/bitcoin-core-dev-tech/2023-04-27-assumeutxo/
[asmap]: https://btctranscripts.com/bitcoin-core-dev-tech/2023-04-27-asmap/
[silent payments]: https://btctranscripts.com/bitcoin-core-dev-tech/2023-04-26-silent-payments/
[libbitcoinkernel]: https://btctranscripts.com/bitcoin-core-dev-tech/2023-04-26-libbitcoin-kernel/
[refactoring (or not)]: https://btctranscripts.com/bitcoin-core-dev-tech/2023-04-25-refactors/
[package relay]: https://btctranscripts.com/bitcoin-core-dev-tech/2023-04-25-package-relay-primer/
[mempool clustering]: https://btctranscripts.com/bitcoin-core-dev-tech/2023-04-25-mempool-clustering/
[project meta discussion]: https://btctranscripts.com/bitcoin-core-dev-tech/2023-04-26-meta-discussion/

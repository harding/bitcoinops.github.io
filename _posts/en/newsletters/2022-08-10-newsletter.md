---
title: 'Bitcoin Optech Newsletter #212'
permalink: /en/newsletters/2022/08/10/
name: 2022-08-10-newsletter
slug: 2022-08-10-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter summarizes a discussion about lowering the
default minimum transaction relay feerate in Bitcoin Core and other
nodes.  Also included are our regular sections with the summary of a
Bitcoin Core PR Review Club, announcements of new releases and release
candidates, and descriptions of notable changes to popular Bitcoin
infrastructure projects.

## News

- **Lowering the default minimum transaction relay feerate:** Bitcoin
  Core only relays individual unconfirmed transactions that pay a
  [feerate of at least one satoshi per vbyte][topic default minimum
  transaction relay feerates] (1 sat/vbyte).  If a node's mempool fills
  with transactions paying at least 1 sat/vbyte, then a higher feerate
  will need to be paid.  Transactions paying a lower feerate can still
  be included in blocks by miners and those blocks will be relayed.
  Other node software implements similar policies.

    Lowering the default minimum feerate has been discussed in the past
    (see [Newsletter #3][news3 min]) but [hasn't been merged][bitcoin
    core #13922] into Bitcoin Core.  The topic saw renewed
    [discussion][chauhan min] in the past couple weeks:

    - *Individual change effectiveness:* it was [debated][todd min] by
      [several][vjudeu min] people how effective it was for individual
      node operators to change their policies.

    - *Past failures:* it was [mentioned][harding min] that the previous
      attempt to lower the default feerate was hampered by the lower
      rate also reducing the cost of several minor denial-of-service
      (DoS) attacks.

    - *Alternative relay criteria:* it was [suggested][todd min2] that
      transactions violating certain default criteria (such as the
      default minimum feerate) could instead fulfill some separate
      criteria that make DoS attacks costly---for example, if a modest amount
      of hashcash-style proof of work committed to the transaction to
      relay.

    The discussion did not reach a clear conclusion as of this writing.

## Bitcoin Core PR Review Club

*In this monthly section, we summarize a recent [Bitcoin Core PR Review Club][]
meeting, highlighting some of the important questions and answers.  Click on a
question below to see a summary of the answer from the meeting.*

[Decouple validation cache initialization from ArgsManager][review club 25527]
is a PR by Carl Dong that separates node configuration logic from the
initialization of signature and script caches.
It is part of the [libbitcoinkernel project][].


{% include functions/details-list.md
  q0="In your own words, what does the `ArgsManager` do?
Why or why not should `ArgsManager` belong in `src/kernel` versus `src/node`?"
  a0="It's a global data structure for handling configuration options
(`.bitcoin/bitcoin.conf` and command line arguments).
It lets users customise the configuration of their nodes.
It's undesirable for the consensus engine (`src/kernel`) to access `ArgsManager` for
any reason, because it could, in principle, allow per-node configuration options
to modify the behavior of the consensus engine. This could lead to
a loss of consensus between nodes. Also, when the [libbitcoinkernel project][] is
complete, it will be possible to build a simple node that's barely more than
the consensus engine, and might not even have this global data structure.
Reducing dependency on globals is always an improvement."
  a0link="https://bitcoincore.reviews/25527#l-35"

  q1="In your own words, what are the validation caches? Why would they belong in
`src/kernel` versus `src/node`?"
  a1="When a new block arrives, the most computationally expensive part of validating
it is validating its transactions; this is part of the consensus engine.
Since most of a block's transactions have already
been seen and validated (when added to the mempool), block validation can
be sped up by caching the (successful) script and signature verifications
that were done earlier. These caches must be part of the
consensus engine, because consensus code refers to them.
If the caching code has a bug, consensus may be
lost if different nodes have diffrent cache sizes.
Consensus code doesn't actually live in `src/kernel` yet; most of it
is in `validation.cpp`.
We refer to _consensus_ as consensus rules themselves, e.g. signature verification.
And we're referring to signature caching as _consensus-critical_ functionality because,
if we have an invalid signature cached, our node is no longer enforcing consensus rules."
  a1link="https://bitcoincore.reviews/25527#l-45"

  q2="What tools do you use for “code archeology” to understand the background of why
a value exists?"
  a2="`git blame filename`; `git log -p filename`; enter
`commit:<commit-hash>` into the
[pulls](https://github.com/bitcoin/bitcoin/pulls) page;
use GitHub `Blame` button when viewing a file.
You can also search for project symbols in the GitHub search bar."
  a2link="https://bitcoincore.reviews/25527#l-132"

  q3="This PR changes the type of `signature_cache_bytes` and
`script_execution_cache_bytes` from `int64_t` to `size_t`.
What is the difference between `int64_t`, `uint64_t`, and `size_t`,
and why should a `size_t` hold these values?"
  a3="The `int64_t` and `uint64_t` types are 64-bits (signed and unsigned,
respectively) across all platforms and compilers. The `size_t` type
is an unsigned integer that's
guaranteed to be able to hold the length (in bytes) of any object
in memory, including an array.
The `size_t` type can be either 32 bits on a 32-bit memory system or
64 bits on a 64-bit memory system. A `size_t` can also hold an array index,
which is one of its most common uses.
It also matches the size of a memory pointer."
  a3link="https://bitcoincore.reviews/25527#l-163"
%}

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [Core Lightning 0.12.0rc1][] is a release candidate for the next major
  version of this popular LN node implementation.

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], and [Lightning BOLTs][bolts repo].*

- [Bitcoin Core #25610][] opts-in the RPCs and `-walletrbf` to [RBF][topic rbf]
  by default. This follows the update mentioned in
  [Newsletter #208][news208 core RBF], enabling node operators to
  switch their node's transaction replacement behavior from the
  default opt-in RBF (BIP125) to full RBF. RPC opt-in by default was
  proposed in 2017 in [Bitcoin Core #9527][] when the primary
  objections were the novelty at the time, the inability to bump
  transactions and the GUI not having functionality to disable RBF---all
  of which have since been addressed.

- [Bitcoin Core #24584][] amends [coin selection][topic coin selection] to prefer input sets
  composed of a single output type. This addresses scenarios in which
  mixed-type input sets reveal the change output of preceding
  transactions. This follows a related privacy improvement to [always
  match the change type][#23789] to a recipient output (see
  [Newsletter #181][news181 change matching]).

- [Core Lightning #5071][] adds a bookkeeper plugin that provides an
  accounting record of movements of bitcoins by the node running the
  plugin, including the ability to track the amount spent on fees.  The
  merged PR includes several new RPC commands.

- [BDK #645][] adds a way to specify which [taproot][topic taproot] spend paths to sign
  for.  Previously, BDK would sign for the keypath spend if it was able,
  plus sign for any scriptpath leaves it had the keys for.

- [BOLTs #911][] adds the ability for an LN node to announce a DNS
  hostname that resolves to its IP address.  Previous discussion about
  this idea was mentioned in [Newsletter #167][news167 ln dns].

{% include references.md %}
{% include linkers/issues.md v=2 issues="25610,24584,5071,645,911,13922,9527" %}
[core lightning 0.12.0rc1]: https://github.com/ElementsProject/lightning/releases/tag/v0.12.0rc1
[news208 core RBF]: /en/newsletters/2022/07/13/#bitcoin-core-25353
[news167 ln dns]: /en/newsletters/2021/09/22/#dns-records-for-ln-nodes
[news181 change matching]: /en/newsletters/2022/01/05/#bitcoin-core-23789
[chauhan min]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-July/020784.html
[todd min]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-July/020800.html
[vjudeu min]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-August/020821.html
[harding min]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-July/020808.html
[todd min2]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-August/020815.html
[news3 min]: /en/newsletters/2018/07/10/#discussion-min-fee-discussion-about-minimum-relay-fee
[#23789]: https://github.com/bitcoin/bitcoin/issues/23789
[review club 25527]: https://bitcoincore.reviews/25527
[libbitcoinkernel project]: https://github.com/bitcoin/bitcoin/issues/24303
[`ArgsManager`]: https://github.com/bitcoin/bitcoin/blob/5871b5b5ab57a0caf9b7514eb162c491c83281d5/src/util/system.h#L172

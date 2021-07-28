*By [ZmnSCPxj][]*

### Introduction

The Taproot upgrade is locked in!
So, what do we do now in Lightning to utilize the new base layer
feature when it finally activates?

Taproot enables the following Lightning features:

* PTLCs over Lightning.
* Taproot-addressed Channels.

Both features are desirable, as they both improve privacy for
Lightning users.

### The Features

#### PTLCs Over Lightning

PTLCs enable a whole menagerie of further features, many of which
Nadav Kohen explained in the [SuredBits blog][suredbits payment points].

Among the features mentioned in the above, one major feature that
PTLCs over Lightning enables is *payment decorrelation*.

In an HTLC-based Lightning payment, the same hash has to be used at
all hops along a multi-hop payment.
Suppose there is a surveillor, someone monitoring payments on
Lightning.
This surveillor can maintain multiple forwarding Lightning nodes.

Suppose one of the surveillor nodes sees a forwarding request with
a particular hash.
Then several milliseconds later, another surveillor node sees a
forwarding request with *the same* hash.
Then with very high probability both forwards are part of the same
overall Lightning payment.
This gives the surveillor a lot of information:

* The ultimate sender of the payment, with fairly high probability,
  is nearer to the first surveillor node than the second surveillor
  node.
* The ultimate receiver is likely nearer to the second surveillor
  node than to the first.
* Nodes that are "between" the surveillor nodes are unlikely to
  be the sender or the receiver.

While the above is couched in conditional language ("fairly high
probability", "likely", "unlikely") any surveillor worth its salt
will extract as much data as it possibly can, and estimate the
probabilities to the utmost of its ability.

Now of course a payer can choose a very twisty path to make the
above analysis wrong (i.e. route randomization), but that has its
drawbacks:

* Twisty paths are costlier *and* less reliable (more nodes
  have to be paid, and more nodes need to *successfully* forward
  in order for the payment to reach the destination).
* Twisty paths are longer, meaning the payer is telling *more*
  nodes about the payment, making it *more* likely they will hit
  *some* surveillor node.
  Thus, twisty paths are not necessarily a perfect improvement
  in privacy.

Now, with PTLCs, we no longer need the *same* hash in a single
Lightning payment.
Instead, as mentioned in previous articles about PTLCs, every
node along a path can be given a scalar that is used to tweak
each forwarded PTLC.
Similarly, every path in a multipath payment can be given a
different set of tweaks.
The upshot here is that PTLCs enable *payment decorrelation*,
in that individual forwards no longer leak the unique identifier
for each Lightning payment.

It should be noted that this is ***not a privacy panacea***.
If a surveillor node sees a forward with a particular timelock,
sending a particular value, happening at a particular wall clock
time, and a second surveillor node sees a forward with a *lower*
timelock, *slightly lower* value, and happening at a *slightly
later* all clock time, then *very likely* those forwards belong to
the same payment path, even if the surveillor nodes can no longer
100% reliably correlate them via a unique identifying hash.

However, what we *do* get are:

* There is now increased uncertainty in the analysis.
  Proper surveillors will always extract as much data as possible
  and will extract probabilities still, but those probabilities
  they can work with are now lower and thus their information is
  that much less valuable.
* Multipath payments get a *lot* more decorrelation between paths.
  Separate paths within a payment will not have strong timelock
  and value correlation with each other, and if Lightning succeeds,
  there should be enough payments that timing correlation is not
  reliable either.
  This is in contrast with today where all paths in a multipath
  payment are trivially correlated by the same identifying hash.
* There is no increase in cost compared to an HTLC (and possibly
  even a slight cost reduction if a PTLC is dropped onchain
  compared to an HTLC dropped onchain --- Lightning HTLC claims
  require two signatures and a preimage, PTLC claims are going
  to require just a single signature).

#### Taproot-addressed Channels

Privacy is multifaceted, and one facet has always been the
correlation between the base layer and the Lightning layer.

Now, one solution that has been passed around for improving the
decorrelation between the base layer and the Lightning layer
has been unpublished channels.
Published channels point to a particular funding outpoint on
the blockchain, and are widely gossiped on Lightning.
Thus, published channels tell everyone that a particular
node owns funds in a particular onchain outpoint, which can
then be used to assist onchain ownership analysis.

By *not* publishing a channel, the thought goes, this
information is not shared and your channel is now "private".

Unfortunately, every Lightning channel is a 2-of-2, and in the
current pre-Taproot Bitcoin, every 2-of-2 is *openly* coded,
for every blockchain explorer to see, in Bitcoin SCRIPT, as a
2-of-2 multisignature, once the output is spent onchain.

And Lightning is the most popular user of 2-of-2 multisignature.
Thus, any blockchain explorer can see an openly-coded 2-of-2
being spent, and then that explorer can guess, with fairly
good probability, that this is a Lightning channel being closed.
The funds can then be traced from there, and if it goes to
another P2WSH then that is likely to be *another* "private"
Lightning channel.
Thus, even unpublished channels are identifiable onchain once
they are closed, with some level of false positives, and further
correlations are still possible.

Taproot, by using Schnorr signatures, allows for n-of-n to look
exactly the same as 1-of-1.
With some work, even k-of-n will also look the same as 1-of-1
(and n-of-n).
This increases the anonymity set, as 2-of-2 spends are
indistinguishable from Taproot 1-of-1, Taproot 2-of-3, and so
on.

In particular, aside from plain 1-of-1 and (mostly) Lightning
2-of-2, many large whales will be using 2-of-3, and all those
addresses will now be indistinguishable from each other.

We can then propose a feature where a Lightning channel is
backed by a UTXO guarded by a Taproot address, i.e. a
Taproot-addressed channel.

This of course increases the *onchain* privacy of unpublished
channels, since there are no identifiable 2-of-2 multisignatures
that can be used to probabilistically say "this spend is probably
the close of some Lightning channel, because it is a 2-of-2 and
Lightning is the most popular user of 2-of-2 signing".

(Still, when considering unpublished channels, remember that
it takes two to tango, and if an unpublished channel is
closed, then one participant (say, a Lightning service provider)
uses the remaining funds for a *published* channel, a blockchain
explorer can guess that the source of the funds has some
probability of having been an unpublished channel that was
closed.)

In addition, Taproot keypath spends require only *one* 64-byte
signature to be published onchain.
This is in contrast with existing Lightning channels, which use
P2WSH 2-of-2, requiring revelation of *two* 33-byte pubkeys, a few
bytes of SCRIPT, and *two* DER-encoded 73-byte signatures.
Thus, closing a Taproot channel is cheaper than closing an
existing pre-Taproot channel.

We should emphasize, however, that you **cannot upgrade an
existing pre-Taproot channel to a Taproot-addressed channel**.
The existing channel uses the existing P2WSH 2-of-2 scheme, and
has to be closed in order to switch to a Taproot-addressed channel.
And the closure of the P2WSH 2-of-2 channel requires a fairly
large amount of bytes.

This (rather small) privacy boost also helps published channels
as well.
Published channels are only gossiped until they are closed.
Once closed, they are no longer gossiped.
Thus, somebody trying to look for published channels will not
be able to connect to any Lightning node and get a list of
*historical* channels; they have to have been online in the
past to store those published channels.

This is a substantive difference between onchain transactions
and published channels.

* You can connect to a random blockchain layer archival fullnode,
  and get *every* onchain transaction from genesis to today.
* You can connect to a random Lightning layer node, and get
  *still-open* published channels currently at the last
  snapshot that node knows about.

If a surveillor wants to see every published channel, it has
to store all that data itself, and cannot rely on any kind of
"archival" node.

Thus, once closed, published channels get slightly more privacy
if they were Taproot-addressed channels, since once closed, they
no longer get gossiped, but their onchain footprint is now
indistinguishable from Taproot 1-of-1 spends.

In conclusion:

* The primary benefit of this is really the slightly lower
  onchain fees involved in a cooperative / mutual close.
  Depending on exact design, it may also slightly lower the
  onchain fees involved in a unilateral close.
* This provides a very small privacy bonus to unpublished
  channels, and an even smaller (possibly too tiny to be worth
  bothering with) privacy bonus to published channels.
* Closing an existing pre-Taproot channel in order to reopen a
  Taproot "Lightning-onchain decorrelated" channel will require
  more fees than what you save above.
  * If you do not pass the funds through a privacy-enhancing
    technology between closing the pre-Taproot channel and
    opening the Lightning-onchain decorrelated channel, then
    the privacy bonus is also pretty much lost --- blockchain
    explorers can guess that the destination Taproot address
    is really yet another Lightning channel.

#### Transitioning To Taproot-requiring Features

It is important to note that I indicated *two* Taproot-requiring
features rather than just one.
The major feature is of course PTLCs, which give us the most
bang (additional enabled features) for the buck (negligible fee
increase, or even a fee reduction), but the secondary one is
getting a Taproot-addressed channel.

The important thing to note is that a pre-Taproot channel *can*,
in principle, be upgraded to support PTLCs, *without* expensive
closing and reopening of the channel to a Taproot-addressed
channel.

PLTCs require Taproot of some kind, but any address can pay to
any other address, including paying from a non-Taproot address
to a Taproot address (otherwise Taproot would be fairly useless
since nobody can move their funds to it!).

Existing channels use a non-Taproot address to back their
funds, but non-Taproot can pay to a Taproot address, and thus,
existing channels *can* host PTLCs, by simply using an offchain
transaction that spends the existing non-Taproot funding output
and creating a Taproot address representing a PTLC.
That "only" requires that both peers of the channel agree on
some protocol to set up PTLCs.

Thus, getting support for the first feature, PTLCs over
Lightning, does not require any cost to users, other than
the developer-hours needed to design and implement the
feature.
Indeed, long-lived nodes need not close their existing channels
and open new ones, they can just keep on using the existing
channels and just wait for the software they and their peers
use to be upgraded to support a common PTLC protocol.

The second feature, however, is tied to opening channels, so
existing channels have to be closed, the funds passed through
some onchain-privacy-enhancing technology (e.g. Wasabi or
JoinMarket), and then the channel reopened with a hiding
Taproot address.

Because the second feature requires onchain activity, it is
more costly to users.
In general, I expect Taproot-addressed channels will be used only
for new channels, and existing channels will be updated
offchain, by upgrading the software on both ends of the channel,
to support PTLCs over Lightning.

* PTLCs over Lightning require that a non-Taproot address (the
  funding outpoint of the channel) pay to a Taproot address
  (the onchain representation of the PTLC).
  This feature is part of Bitcoin already, thus can in
  principle be supported --- "just" needs design and
  implementation.
  Nodes that want to upgrade do not need to close existing
  channels and reopen them.
* Lightning-onchain decorrelated channels require that a
  Taproot address be used in the channel funding outpoint.
  Nodes that want to truly transition to this new scheme
  need to close existing channels, and very likely also
  pass the funds through a privacy-enhancing technology,
  then reopen new ones.

Neither feature requires the other, though given the major
benefits of PTLCs over Lightning, and the relatively low cost
it has if implemented without requiring Taproot-addressed
channels, I think Lightning developers would prefer to
prioritize PTLCS over Lightning.

### Lightning "Consensus"

Unlike the base layer, there is no need for a *global* consensus
at the Lightning level.
That is, there is no need for *all* Lightning nodes to follow the
exact sets of rules; there is some amount of leeway in Lightning
that is not allowed in the blockchain layer.

Instead, what Lightning requires between nodes are two kinds of
compatibility:

* Link-level Compatibility.
* Remote Compatibility.

What do the above kinds of compatibility mean?

These are related to two main forms of communication between
Lightning Network nodes.

One form of communication is direct, over a TCP link, between peers
who have (or want to have) a channel between them.

The other form of communication is indirect, where one node wraps the
information in an onion and sends out a payment with that onion, and
another node --- not directly channeled with the sender --- opens the
onion and processes the information.

Link-level compatibility is required for features that need to be
coordinated by channel counterparties in the direct TCP link.
Remote compatibility is required for features that need to be
coordinated over the onion-transmitting payment.

Let me provide examples:

* Turbo channels (i.e. channels that support sending before the
  channel funding transaction is confirmed, a.k.a. 0-conf channels)
  require link-level compatibility but not remote compatibility.
* Keysend (i.e. sending to a published node public key without an
  invoice) requires remote compatibility but not link-level
  compatibility.

Turbo channels require link-level compatibility because two nodes
that want to establish a turbo channel between them need to agree
that a particular channel **is** a "turbo" channel.
When a sender wants to send before the channel is confirmed, the
other side needs to agree to allow the send and not respond with
an error message.

At the same time, turbo channels do not need remote compatibility
--- as long as the first forwarding node is willing to forward
the outgoing payment from the sender, nobody else cares if that
forwarding node got paid via a turbo channel or not.

On the other hand, keysend does not require link-level
compatibility.
Keysend is about how the receiver of the payment will be able to
somehow get the preimage needed to claim the funds.
None of the intervening forwarding nodes need to know about the
keysend feature, only the ultimate sender needs to somehow hand
over the preimage to the ultimate receiver of the payment.

Thus, keysend requires remote compatibility but does not require
link-level compatibility.

Now let us consider the Taproot-requiring features:

* PTLCs over Lightning requires *both* link-level *and*
  remote compatibility.
* Taproot-addressed channels require just link-level
  compatibility.

#### PTLCs Over Lightning: Link-level and Remote

The reason PTLCs over Lightning require link-level compatibility
is that PTLCs are, at the low level, sent from one node to another
over a channel.
Thus, both nodes participating in a channel need to talk the
same protocol to establish a new PTLC on a channel.

Now, a major complication is that, if you want to send a
PTLC from a sender to a remote receiver, where the sender is
not directly channeled with the receiver (i.e. "remote"),
*every* forwarding node along the way has to support PTLCs,
as well.
It is fairly useless if you and every node you are channeled
with have some kind of PTLC support, if the rest of the network
has no support for PTLCs, you cannot send out PTLCs (and reap
their benefits) to anyone else other than your direct peers,
which makes it a fairly weak "network".

Not all forwarding nodes need to support *the same* link-level
protocol for PTLCs, there could be multiple link-level
PTLC protocols.
However, having to support multiple link-level protocols is
added maintenance burden and I *hope* we do not have too many
such PTLC link-level protocols (ideally just one).

Thus:

* PTLCs over Lightning require that two nodes on the same
  channel agree to establish a PTLC between them, thus requires
  link-level compatibility.
* PTLCs over Lightning require that the ultimate sender and the
  ultimate receiver understand this new thing, with payment
  points instead of payment hashes and payment scalars instead
  of payment preimages, thus requires remote compatibility.
  Worse, it requires that *every* forwarding node between them
  *also* understand this new thing.

#### Taproot-addressed Channels: Link-level

On the other hand, the actual funding transaction outpoint is
really a concern of the two nodes that use the channel.

Other nodes on the network will not care about what secures
the channel between any two nodes.
Just as other nodes on the network do not care whether you
secure your channel using a 0-conf turbo channel scheme or
not, other nodes will also not care whether you secure your
channel using a Taproot scheme or not.

Thus:

* Taproot-addressed channels require that the two nodes
  establishing a channel agree on what the Taproot scheme looks
  like, thus requires link-level compatibility.
* Other nodes on the network do not care about how the two
  nodes on the Taproot channel secure their funds, thus
  does not require remote compatibility.

On the **other** hand, there *is* a detail I have elided, and
that is channel gossip.

Published channels are shared over the Lightning gossip network.
And published channels point to a funding outpoint on the
blockchain layer.

When a node receives a gossiped published channel, it consults
its own trusted blockchain fullnode, checking if the funding
outpoint exists, and more importantly **has the correct address**.

Checking the address helps ensure that it is difficult to spam
the channel gossip mechanism; you need actual funds on the
blockchain in order to send channel gossip.

Now, if the Lightning node is completely unaware of the new
Taproot addresses for channels, then it cannot validate the
address of the gossiped channel, and will think it does not
really exist and ignore the gossiped channel.
Then the channel will not be used by that node when sending.

Thus, in practice, even Taproot-addressed channels require some
amount of remote compatibility; otherwise, senders will ignore
these channels for routing, as they cannot validate that those
channels *exist*.

However, if such channels are mostly only on the "edges" of the
network (i.e. as unpublished channels between Lightning service
providers and non-forwarding users), then there is no need for
remote compatibility with these channels.

### Time Frames

Of course, just as the perennial question for Taproot was "when
Taproot?", I think the perennial question for Taproot-requiring
features on Lightning is going to be "when Taproot-requiring
features on Lightning?".

I think the best way to create time frames for features on a
distributed FOSS project is to look at *previous* features and
how long they took, and use those as the basis for how long
features will take to actually deploy.

Yes, details matter, but they also do not: from a high enough
vantage point, the unexpected hardships of some aspect of
development and the unexpected non-hardships of other aspects
of development cancel out, and we are left with every major
feature being roughly around some average time frame, with
any unexpectedly high bonus or malus being "just noise".

Yes, there are more developers now, that also means we need
to get greater agreement on various details and more
implementation-specific concerns ("mythical man-month").
Yes, we now know more today about how Lightning works, but
what we know is how Lightning works pre-Taproot, and we
might actually have to unlearn some of those lessons in a
post-Taproot world.
If we want to make **accurate** estimates as opposed to
**feel-good** estimates, we should use methods that avoid
the [planning fallacy][WIKIPEDIAPLANNINGFALLACY].

Thus, we should just look for a similar previous completed
feature, and *deliberately ignore* its details, only looking
at how long the feature took to implement.

The most recent new major feature that I believe is most
similar to PTLCs over Lightning is dual-funding.

Lisa Neigut created an initial proposal for a dual-funding
protocol in [lightning-rfc PR#524][bolts #254].

Looking at the date, this PR was opened on 2018-12-05.

Recently, Lisa wrote an article announcing the [first dual-funded
channel on mainnet][neigut first dual funded].

That article points to a particular [transaction][first dual funded tx]
as the first mainnet dual-funded channel.

Looking at the confirmation time of that transaction, this
channel was fully opened at 2021-05-04, almost exactly 2
years and 6 months after the PR was created.

However, I would like to point out that dual-funding only
requires link-level compatibility.
PTLCs over Lightning require both link-level and
remote compatibility, and thus I feel justified in giving
this feature a +50% time modifier due to the added
complication, for an estimate of 3 years and 9 months.

In addition, as of the time of this writing, there are no
PRs to propose PTLCs over Lightning yet.
Thus, the estimate from today to the first mainnet
PTLC-over-Lightning will take longer.

It is difficult for me to figure out how to estimate
the time from base layer feature activation to initial
Lightning layer concrete proposal, since the previous
base layer feature SegWit enabled the entire Lightning
network, and the [concrete proposal for Lightning][russell deployable ln]
happened *before* SegWit activation (the proposal was
written in 2015, SegWit got activated 2017).

Thus, for now, I cannot estimate how long it would take
from the time of this writing to someone proposing an
actual PTLCs-on-Lightning protocol.
As of this writing I am unaware of any published proposal
for PTLCs over Lightning (I mean a technically detailed
one, with messages, message formats, involved mathematics,
MUST-ard and SHOULD-ard, and so on).
However, I believe that once such a protocol is proposed,
it will take between 2 years and 6 months, to 3 years and
9 months for this feature to reach mainnet in some kind of
practical form.

For Taproot-addressed channels, we should note that while
this is "only" a link-level feature, it also has lower
benefits.
Thus, I expect it will be lower priority.
Assuming most developers prioritize PTLC-over-Lightning,
then I expect Taproot-addressed channels will start getting
worked on by the time the underlying `SIGHASH_NOINPUT` or
other ways to implement Decker-Russell-Osuntokun ("Eltoo").

### Conclusion

* There are two primary Lightning features enabled by
  Taproot:
  * PTLCs over Lightning, which enables payment
    decorrelation for a small boost to Lightning payment
    privacy, as well as a bunch of more advanced protocols
    on top of Lightning.
  * Taproot-addressed Channels, which provide a small
    privacy benefit to channels, reducing the correlation
    between channels and the blockchain.
* PTLCS over Lightning are practically "free" for users
  (no payment required to upgrade channels/nodes to support
  them, just need implementor-days to implement).
* Taproot-addressed channels are cheaper for *new* users,
  but existing users need to pay in order to upgrade.
* Implementing PTLCs over Lightning will take approximately
  2.5 to 4 years, by my estimation.
* Implementing Taproot-addressed channels might take a
  shorter time but as the benefit of those is lower (and
  the cost to users is higher) they might end up being
  deferred, at which point they may be subsumed by
  Decker-Russell-Osuntokun.

{% include references.md %}
{% include linkers/issues.md issues="254" %}
[zmnscpxj]: https://zmnscpxj.github.io/about.html
[suredbits payment points]: https://suredbits.com/payment-points-monotone-access-structures/
[WIKIPEDIAPLANNINGFALLACY]: https://en.wikipedia.org/wiki/Planning_fallacy
[neigut first dual funded]: https://medium.com/blockstream/c-lightning-opens-first-dual-funded-mainnet-lightning-channel-ada6b32a527c
[first dual funded tx]: https://blockstream.info/tx/91538cbc4aca767cb77aa0690c2a6e710e095c8eb6d8f73d53a3a29682cb7581
[russell deployable ln]: https://github.com/ElementsProject/lightning/blob/master/doc/deployable-lightning.pdf

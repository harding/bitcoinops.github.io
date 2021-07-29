*By [ZmnSCPxj][]*

Taproot enables the following Lightning features:

* PTLCs over Lightning.
* Taproot-addressed Channels.

Both features improve privacy for
Lightning users.  Let's look at each and then consider how hard it'll be
to upgrade Lightning to use them.

### PTLCs Over Lightning

PTLCs enable [many features][suredbits payment points], with a major
feature for Lighting being [payment decorrelation][p4tr ptlcs] without
any need randomize routes.[^route randomization] Every node along a
single-path or multipath route can be given a scalar that is used to
tweak each forwarded PTLC, enabling *payment decorrelation* where
individual forwards no longer leak the unique identifier for each
Lightning payment.

PTLCs are ***not a privacy panacea***.
If a surveillor node sees a forward with a particular timelock,
sending a particular value, happening at a particular wall clock
time, and a second surveillor node sees a forward with a *lower*
timelock, *slightly lower* value, and happening at a *slightly
later* all clock time, then *very likely* those forwards belong to
the same payment path, even if the surveillor nodes can no longer
100% reliably correlate them via a unique identifying hash.

However, what we *do* get are:

* PTLCs increase the uncertainty in the analysis.
  The probabilities surveilors
  can work with are now lower and thus their information is
  that much less valuable.
* Multipath payments get a *lot* more decorrelation between paths.
  Separate paths within a payment will not have strong timelock
  and value correlation with each other, and if Lightning succeeds,
  there should be enough payments that timing correlation is not
  reliable either.
* There is no increase in cost compared to an HTLC (and possibly
  even a slight cost reduction due to [multisignature efficiency][p4tr
  multisignatures]).

---

A pre-Taproot channel *can*,
in principle be upgraded to support PTLCs *without* expensive
closing and reopening of the channel.
Existing channels can host PTLCs by simply using an offchain
transaction that spends the existing non-Taproot funding output
to a Taproot output containing a PTLC.
That "only" requires that both peers of the channel agree on
some protocol to set up PTLCs.

Thus getting support for PTLCs over
Lightning does not require any cost to users beyond upgrading their
software.

---

PTLCs over Lightning require link-level compatibility
because they're sent from one node to another
over a channel.
Thus, both nodes participating in a channel need to talk the
same protocol to establish a new PTLC on a channel.

A major complication is that sending a
PTLC from a sender to a remote receiver, where the sender is
not directly channeled with the receiver (i.e. "remote"),
*every* forwarding node along the way has to support PTLCs,
as well.

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

### Taproot-addressed Channels

One solution for improving the
decorrelation between the base layer and the Lightning layer
has been unpublished channels---channels whose existence isn't
gossiped on Lightning.

Unfortunately, every Lightning channel is a 2-of-2, and in the
current pre-Taproot Bitcoin, every 2-of-2 is *openly* coded.
Lightning is the most popular user of 2-of-2 multisignature,
so any blockchain explorer can see a 2-of-2
being spent and guess with fairly
good probability that this is a Lightning channel being closed.
The funds can then be traced from there, and if it goes to
another P2WSH then that is likely to be *another* "private"
Lightning channel.
Thus, even unpublished channels are identifiable onchain once
they are closed, with some level of false positives.

Taproot, by using Schnorr signatures, allows for n-of-n to look
exactly the same as 1-of-1.
With some work, even k-of-n will also look the same as 1-of-1
(and n-of-n).
We can then propose a feature where a Lightning channel is
backed by a UTXO guarded by a Taproot address, i.e. a
Taproot-addressed channel, which increases the *onchain* privacy of unpublished
channels.[^two-to-tango]

<!-- P2WSH 2-of-2: OP_0 <sig> <sig> <2 <key> <key> 2 OP_CMS>
             219 =   1 + 1+72 +1+72 +1+1+1+33+1+33+1+1
             54.75 = 219/4
     P2TR: <sig>
             64
             16 = 64/4

    Comparsion:
      38.75 = 54.75 - 16
      ~70% = 1 - 16/54.75
-->

In addition, Taproot keypath spends are 38.5 vbytes (70%) smaller than
Lightning's existing P2WSH spends.  Unfortunately, you **cannot upgrade an
existing pre-Taproot channel to a Taproot-addressed channel**.
The existing channel uses the existing P2WSH 2-of-2 scheme, and
has to be closed in order to switch to a Taproot-addressed channel.

This (rather small) privacy boost also helps published channels
as well.
Published channels are only gossiped until they are closed, so
somebody trying to look for published channels will not
be able to learn about
*historical* channels.
If a surveillor wants to see every published channel, it has
to store all that data itself, and cannot rely on any kind of
"archival" node.

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

---

The actual funding transaction outpoint is
really a concern of the two nodes that use the channel.
Other nodes on the network will not care about what secures
the channel between any two nodes.

However, published channels are shared over the Lightning gossip network.
When a node receives a gossiped published channel, it consults
its own trusted blockchain fullnode, checking if the funding
outpoint exists, and more importantly **has the correct address**.
Checking the address helps ensure that it is difficult to spam
the channel gossip mechanism; you need actual funds on the
blockchain in order to send channel gossip.

Thus, in practice, even Taproot-addressed channels require some
amount of remote compatibility; otherwise, senders will ignore
these channels for routing, as they cannot validate that those
channels *exist*.

### Time Frames

Of course, just as the perennial question for Taproot was "when
Taproot?", I think the perennial question for Taproot-requiring
features on Lightning is going to be "when Taproot-requiring
features on Lightning?".

I think the best way to create time frames for features on a
distributed FOSS project is to look at *previous* features and
how long they took, and use those as the basis for how long
features will take to actually deploy.[^planning-details]

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

[^route-randomization]:
    A payer can choose a very twisty path (i.e. route randomization) to
    make HTLC correlation analysis wrong, but that has its drawbacks:

    * Twisty paths are costlier *and* less reliable (more nodes
      have to be paid, and more nodes need to *successfully* forward
      in order for the payment to reach the destination).
    * Twisty paths are longer, meaning the payer is telling *more*
      nodes about the payment, making it *more* likely they will hit
      *some* surveillor node.
      Thus, twisty paths are not necessarily a perfect improvement
      in privacy.

[^planning-details]:
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

[^two-to-tango]:
    When considering unpublished channels, remember that
    it takes two to tango, and if an unpublished channel is
    closed, then one participant (say, a Lightning service provider)
    uses the remaining funds for a *published* channel, a blockchain
    explorer can guess that the source of the funds has some
    probability of having been an unpublished channel that was
    closed.

{% include references.md %}
{% include linkers/issues.md issues="254" %}
[zmnscpxj]: https://zmnscpxj.github.io/about.html
[suredbits payment points]: https://suredbits.com/payment-points-monotone-access-structures/
[WIKIPEDIAPLANNINGFALLACY]: https://en.wikipedia.org/wiki/Planning_fallacy
[neigut first dual funded]: https://medium.com/blockstream/c-lightning-opens-first-dual-funded-mainnet-lightning-channel-ada6b32a527c
[first dual funded tx]: https://blockstream.info/tx/91538cbc4aca767cb77aa0690c2a6e710e095c8eb6d8f73d53a3a29682cb7581
[russell deployable ln]: https://github.com/ElementsProject/lightning/blob/master/doc/deployable-lightning.pdf
[p4tr ptlcs]: / {% comment %}FIXME{% endcomment %}
[p4tr multisignatures]: / {% comment %}FIXME{% endcomment %}

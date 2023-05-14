<!--
  300 to 1000 words
  put title in main newsletter
  put links in this file
  for any subheads use h3 (i.e., ###)
  illustrations welcome (max width 800px)
  if uncertain about anything, just do what seems best and harding will edit
-->

Many nodes on the Bitcoin network store unconfirmed transactions in an
in-memory pool, or "mempool." This cache is a very useful resource
each node and, coupled with their connections on the peer-to-peer
network, provides a censorship-resistant and private way of making
payments.

For an individual node, participating in transaction relay is a means
of downloading and validating blocks gradually rather than in spikes.
Every ~10 minutes when a block is found, nodes without a mempool
experience a bandwidth spike, followed by a computation-intensive
period validating each transaction.  On the other hand, nodes with a
mempool have typically already seen all of the block transactions and
stores them in their mempools. With compact block relay (fixme: 152
link), these nodes just download a block header along with shortids,
and then reconstruct the block using transactions in their mempools.
This amount of data is tiny compared to the size of the block (fixme:
stats?).  Validating the transactions is also much faster: the
signatures and scripts verified (and cached), timelock requirements
already calculated, and relevant UTXOs loaded from disk if necessary.
The node can also forward the block onto its other peers very quickly,
dramatically increasing network-wide block propagation speed and
reducing the frequency of stale blocks.

Mempools can also be used to build a "trustless" fee estimator. The
market for block space is a fee-based auction, and keeping a mempool
allows users to have a better sense of what others are bidding and
what bids have been successful in the past.

However, there is no such thing as "The Mempool" - each node may have
a different mempool. Submitting a transaction to one node does not
necessarily mean that it has made its way to miners. Some users find
this uncertainty frustrating, and wonder, "why don't we just submit
transactions directly to miners?"

Consider a Bitcoin network in which all transactions are sent directly
from users to miners. One could censor and surveil financial activity
by requiring the small number of entities to log the IP addresses
corresponding to each transaction, and refuse to accept any
transactions matching a particular pattern. This type of Bitcoin may
be more convenient at times, but would be missing a few of Bitcoin's
most valued properties.

Bitcoin's censorship-resistance and privacy come from its peer-to-peer
network. In order to relay a transaction, each node may connect to
some anonymous set of peers, each of which could be a miner or
somebody connected to a miner. This method helps obfuscate which node
a transaction originates from as well as which node may be responsible
for confirming it. Someone wishing to censor particular entities may
target miners, popular exchanges, or other centralized submission
services, but it would be difficult to block anything completely.

In summary, a mempool is an extremely useful cache that allows nodes
to amortize block download and validation, and gives users access to
better fee estimation. At a network level, mempools support a
distributed transaction and block relay network. All of these benefits
are most pronounced when everybody sees all transactions before miners
include them in blocks - just like any cache, it is most useful when
it's "hot" and must be limited in size to fit in memory. This leads us
to our first example of and reason for mempool policy: transaction
feerate, which helps nodes guess which transactions are most likely to
be confirmed.

Next week's section will dive further into mempool policy and its uses
in protecting network resources, assisting in safer soft forks,
avoiding denial of service attacks, and more.

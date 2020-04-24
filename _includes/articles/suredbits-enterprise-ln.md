{:.post-meta}
by Roman Taranchenko

After the first excitement of sending and, more importantly, receiving a
payment over the Lightning Network has faded away, it’s always good to
think about how to operate your node in a safe and reliable way.
Failures almost always happen unexpectedly. How do you recover after a
possible failure? How do you make backups reliable? How do you keep the
seed in a secure location? Et cetera, et cetera…

At [Suredbits][] we use Eclair for our nodes. Even though Eclair is
pretty robust on its own, we took some steps to make it even more
reliable. Such as using PostgreSQL as a database backend [(there is a PR
in review at the time of writing)][db pr] and [AWS Secrets Manager][] to
store private keys.

Eclair has a built-in online backup feature, but it requires manual
setup and script writing to automate, which is not really scalable and
is error prone. Running PostgreSQL at AWS RDS allows us to automate
backups and replication in the way almost every DevOps engineer is
familiar with, and to restore the database state when needed more
easily.

Using PostgreSQL as a remote database backend makes node failover
simpler to implement, because if the node crashes for some reason
there’s no need to restore the database from a backup, all you need is
to point a new Eclair instance to the correct database server. [Here’s a
quick demo of an automated failover implemented with two Eclair
instances, and AWS RDS, ELB, and NAT Gateway.][failover demo]

In the failover scenario depicted in the demo, we needed a secure way to
share the node’s seed  private key between the Eclair instances. Eclair
stores it in a file on the local file system and the seed file should be
backed up somewhere and restored when needed. The current implementation
requires extra steps to do so in an automated fashion. AWS Secrets
Manager is an encrypted storage specifically designed to securely store
various kinds of secrets, including database passwords and encryption
keys. All you need to do to share the seed between the instances is to
point them to the correct secrets location in the config file. And once
configured, the instance can be stored as an AMI image, and re-imaged as
many times as needed without manual configuration.

The measures we took are just the first steps to building
enterprise-grade Lightning nodes. There are still some more problems
that need to be solved. For example, which Hardware Security Module
(HSM) can be used for a Lightning node, or how to failover a Bitcoin
Core node in a multi-instance setting. But we believe that our work is a
solid base for scaling out Eclair and making it more fault-tolerant.

More on this topic: <https://www.youtube.com/watch?v=tbwy9mJIrZE>

Disclaimer: Since private keys are involved, don't use third party cloud
services without a thorough risk assessment.

[suredbits]: https://suredbits.com
[db pr]: https://github.com/ACINQ/eclair/pull/1249
[aws secrets manager]: https://github.com/rorp/eclair/tree/aws_secretsmanager
[failover demo]: https://youtu.be/L2DtolwS8ew

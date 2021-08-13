# B9MulticastDelegate

[![Swift Version](https://img.shields.io/badge/Swift-5.3+-EE5533.svg?style=flat-square)](https://swift.org)
[![Swift Package Manager](https://img.shields.io/badge/spm-compatible-EE5533.svg?style=flat-square)](https://swift.org/package-manager)
[![Build Status](https://img.shields.io/github/workflow/status/b9swift/MulticastDelegate/Swift?style=flat-square&colorA=333333&colorB=EE5533)](https://travis-ci.org/b9swift/MulticastDelegate)

Multicast delegate is a delegate that can have more than one element in its invocation list.

## Installation

Using Swift Package Manager or import manually.

你也可以使用 [gitee 镜像](https://gitee.com/b9swift/MulticastDelegate)。

## Features

- NSHashTable free. It results better performance, support Liunx.
- MulticastDelegate confirms `Sequence`, which means that lots of sequence features available.
- Thread safe.
- Other delightful details, eg: error handling optimization, debug log optimization.

## Background

> I'm a big fan of the multicast delegate. I have "invented" and used it since 2014.
>
> As Swift’s ABI is stabilized, it's time to move a Swift improvment.
>
> But I cannot find a satisfied implementation everywhere. So I write one.

## Alternatives

- [jonasman/MulticastDelegate](https://github.com/jonasman/MulticastDelegate) - Use NSHashTable. Operator overloading is not a good idea in my opinion, it is not intuitive and reduces readability. API does not meet design guidelines (Omit needless words).
- [elano50/MulticastDelegateKit](https://github.com/elano50/MulticastDelegateKit) - Use NSHashTable.
- [Kevin Lundberg's](https://www.klundberg.com/blog/notifying-many-delegates-at-once-with-multicast-delegates/) - Generic type should not be `AnyObject`. API does not meet design guidelines (Omit needless words).
- [Greg Read's](http://www.gregread.com/2016/02/23/multicast-delegates-in-swift/) - Missing dupracate check when adding. API does not meet design guidelines (Omit needless words). I dislike remove when invoking.
- [Ivan's](https://medium.com/@ivan_m/multicast-on-swift-3-and-mvvm-c-ff74ce802bcc) - Missing dupracate check when adding. It is odd using an equatable weak wrapper to check duplicates.

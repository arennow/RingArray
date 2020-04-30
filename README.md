# RingArray

RingArray is a Swift implementation of a [Circular Buffer](https://en.wikipedia.org/wiki/Circular_buffer), but without the wraparound overwriting behavior. That is, if you make a `RingArray` with a capacity of 10, and add 11 elements to it, the contents will be transferred to a new, larger buffer, and no data will be lost. This should have approximately the same performance characteristics as any growable array, but with O(1) front-end removals, which is useful for queues of various kinds. The downside is that element contiguity isn't guaranteed. 

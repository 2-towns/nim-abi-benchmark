import
  std/strformat,
  std/random,
  stint,
  times,
  sequtils,
  strutils,
  contractabi,
  web3,
  questionable/results


type CustomType = object
  a: uint16
  b: string

type StorageDeal = object
  client: array[20, byte]
  provider: array[20, byte]
  cid: array[32, byte]
  size: uint64
  duration: uint64
  pricePerByte: UInt256
  signature: array[65, byte]
  metadata: string

func encode(encoder: var contractabi.AbiEncoder, custom: CustomType) =
  encoder.write( (custom.a, custom.b) )

func decode(decoder: var contractabi.AbiDecoder, T: type CustomType): ?!T =
  let (a, b) = ?decoder.read( (uint16, string) )
  success CustomType(a: a, b: b)

func encode(encoder: var contractabi.AbiEncoder, deal: StorageDeal) =
  encoder.write((
    deal.client,
    deal.provider,
    deal.cid,
    deal.size,
    deal.duration,
    deal.pricePerByte,
    deal.signature,
    deal.metadata
  ))

func decode(decoder: var contractabi.AbiDecoder, T: type StorageDeal): ?!T =
  let (
    client,
    provider,
    cid,
    size,
    duration,
    pricePerByte,
    signature,
    metadata
  ) = ?decoder.read((
    array[20, byte],
    array[20, byte],
    array[32, byte],
    uint64,
    uint64,
    UInt256,
    array[65, byte],
    string
  ))
  success StorageDeal(
    client: client,
    provider: provider,
    cid: cid,
    size: size,
    duration: duration,
    pricePerByte: pricePerByte,
    signature: signature,
    metadata: metadata
  )

proc randomBytes[N: static int](): array[N, byte] =
  var a: array[N, byte]
  for b in a.mitems:
      b = rand(byte)
  return a

proc compare(timea: float, timeb: float, description: string ) =
  if timeb > timea:
    let ratio = timea.float / timeb.float
    echo description & "in web3 is {ratio:.2f}x slower than in contractabi"
  else:
    let ratio = timeb.float / timea.float
    echo description & "in web3 is {ratio:.2f}x faster than in contractabi"

const Iterations = 100_000

proc benchmarkEncode(input: auto): seq[byte] =
  var start = cpuTime()
  var bytes: seq[byte]
  var encodedA: seq[byte]
  for _ in 0 ..< Iterations:
    encodedA = contractabi.AbiEncoder.encode(input)
  var durationA = cpuTime() - start
  echo &"contractabi: Encoding {$typeof(input)} took {(durationA * 1000).int}ms"

  var encodedB: seq[byte]
  start = cpuTime()
  for _ in 0 ..< Iterations:
    encodedB = Abi.encode(input)
  var durationB = cpuTime() - start
  echo &"web3       : Encoding {$typeof(input)} took {(durationB * 1000).int}ms"

  if durationB > durationA:
    let ratio = durationB / durationA
    echo &"Encoding {$typeof(input)} in web3 ms is {ratio:.2f}x slower than in contractabi\n"
  else:
    let ratio = durationA / durationB
    echo &"Encoding {$typeof(input)} in web3 ms is {ratio:.2f}x faster than in contractabi\n"

  start = cpuTime()
  for _ in 0 ..< Iterations:
    discard contractabi.AbiDecoder.decode(encodedA, typeof(input))
  durationA = cpuTime() - start
  echo &"contractabi: Decoding {$typeof(input)} took {(durationA * 1000).int}ms"

  encodedB = Abi.encode(input)
  start = cpuTime()
  for _ in 0 ..< Iterations:
    discard Abi.decode(encodedB, typeof(input))
  durationB = cpuTime() - start
  echo &"web3       : Decoding {$typeof(input)} took {(durationB * 1000).int}ms"

  if durationB > durationA:
    let ratio = durationB / durationA
    echo &"Decoding {$typeof(input)} in web3 ms is {ratio:.2f}x slower than in contractabi\n"
  else:
    let ratio = durationA / durationB
    echo &"Decoding {$typeof(input)} in web3 ms is {ratio:.2f}x faster than in contractabi\n"

  return bytes

let smallIntEncoded = benchmarkEncode(16.uint16)
let helloWorldEncoded = benchmarkEncode("Hello world")
let longStringEncoded = benchmarkEncode(repeat('x', 5_000))
let randomBytes32Encoded = benchmarkEncode(randomBytes[32]())
let randonBytes1024Encoded = benchmarkEncode(randomBytes[1024]())

let x =  CustomType(a: 42'u16, b: "Hello, World!")
let customTypeEncoded =benchmarkEncode(x)

let deal = StorageDeal(
  client: randomBytes[20](),
  provider: randomBytes[20](),
  cid: randomBytes[32](),
  size: 1024'u64,
  duration: 365'u64,
  pricePerByte: 1000.u256,
  signature: randomBytes[65](),
  metadata: "Sample metadata for storage deal"
)
let dealEncoded = benchmarkEncode(deal)

import prettyjson from 'prettyjson'
import Parser from './parser'

var parser = new Parser()
// parser.feed(`module Utils.Tree
// exposing
//     ( Forest
//     , Tree
//     , createEmptyForest
//     , (<|>)
//     , Maybe(Just)
//     , Maybe(..)
//     )`)

// parser.feed(
//   'effect module Debounce where { command = MyCmd } exposing (debounce)'
// )

parser.feed(
  'effect module Debounce where { command = MyCmd } exposing (debounce)'
)

var value = parser.results
// console.log(JSON.stringify(value))
console.log(prettyjson.render(value))

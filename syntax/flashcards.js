#!/usr/bin/node

const fs = require('fs')
const readline = require('readline')
const file = "/home/octopus/game/study/languages/lexemes.2.normalise.log"

var data = []
readline.createInterface({input: fs.createReadStream(file)})
  .on('line', line => {
    if (/^[0-9_X]{13}.{44}│/.test(line)) {
      data.push([line, ""])
    } else {
      data[data.length-1][1] += line + "\n"
    }
  })
  .on('close', () => {
    console.log(data)
  })


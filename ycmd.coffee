child_process = require 'child_process'
path = require 'path'
process = require 'process'

ycmd =
  repo: 'https://github.com/Qusic/ycmd.git'
  commit: '4992a48b5e26e0a6263cd20597869c790edc567c'
  root_dir: __dirname
  ycmd_dir: path.resolve __dirname, 'ycmd'

  spawn: (command, args, cwd = @root_dir) ->
    child_process.spawnSync command, args, {
      cwd: cwd
      encoding: 'utf8'
    }

  clone: () ->
    result = @spawn 'git', ['clone', @repo], @root_dir
    return result.status is 0
  checkout: () ->
    result = @spawn 'git', ['checkout', @commit], @ycmd_dir
    return result.status is 0
  remove: () ->
    result = @spawn 'rm', ['-rf', @ycmd_dir]
    return result.status is 0

  version: () ->
    result = @spawn 'python', ['-c', '''
      from sys import stdout
      from ycm_client_support import YcmCoreVersion
      stdout.write(str(YcmCoreVersion()))
    '''], @ycmd_dir
    return if result.status is 0 then result.stdout else null

unless ycmd.checkout() or (ycmd.remove() and ycmd.clone() and ycmd.checkout())
  console.error 'Failed to fetch ycmd from github.'
  process.exit 1

unless ycmd.version() is '17'
  console.warn 'Ycmd native parts have to be recompiled before this package works.'
  process.exit 0

console.log 'Everything looks fine. You are good to go!'
process.exit 0
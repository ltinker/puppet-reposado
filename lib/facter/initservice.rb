require 'puppet'

Facter.add("initservice") do
  confine :kernel => :Linux
  setcode do
    `ls -l /proc/1/exe | awk '{n=split($NF, N, "/"); { print N[n] }}'`
  end

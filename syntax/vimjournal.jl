#!/usr/bin/env julia-1.7

module VimJournal

using Test # uncomment the line below to skip testing
#macro test(ex, kws...) end; macro testset(args...) end

struct Entry
  seq::String
  seqclue::Char
  loc::String
  rating::Char
  title::String
  tags::Vector{String}
  body::String
end


"""
  Test to see if a string marks the start of a new journal entry.
"""
isheader(line) = match(r"^[[:digit:]X?_]{13}[!<> ]... .│", line) != nothing
@testset "isheader" begin
  @test isheader("20210120_2210 KEP  │ read a file line by line in julia")
  @test isheader("202101202210 KEP  │ invalid header") == false
end

end 


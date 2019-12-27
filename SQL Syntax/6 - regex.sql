# Regex
-- ^  begin      --      $ end       --     | or
-- [[:<:]]  match begin        --         [[:>:]]  match end
-- [abc]    match one
-- [^xyz]   many any not here


 
# Characters
-- [:digit:] -- [:alpha:] -- [:space:] -- [:punct:] -- [:upper:] -- [:alnum:]


# Matching
-- {3}      match 3 times
-- {3,5}    match 3 - 5 times
-- {3,}     match 3+ times
-- . match any       -- ?  match 0 or 1         -- * match 0+          -- +  match 1+


# End with one of the following
.. where vendor_name REGEXP "(Inc|Corporation|Co)$";

# Include "of" (between)
.. where vendor_name REGEXP "  [[:<:]]  of  [[:>:]]  ";

# ends with 5 digit number
.. where REGEXP '[[:<:]]  [[:digit:]]{5}  $';



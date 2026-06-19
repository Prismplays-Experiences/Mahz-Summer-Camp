While not part of the style guide proper, this page collects common but not obvious issues within Lua code. Such issues tend to catch people out leading to hard to track down errors. The first defense against such errors is knowing they can exist.

See also: https://www.luafaq.org/gotchas.html

## Boolean Operations on Non-Boolean Values

A common pattern in our codebase is to use `and` and `or` to imitate a ternary operator. This works because anything other than `nil` or `false` evaluates as truthy, and the boolean operators use short-circuit logic and return the value of the last operand evaluated. So:

```text
local a = {u="v"}
local b = 1
local c = false
local d = a or b  -- d equals a
local e = c and a or b  -- e equals b
```

The problem is this gives an unexpected answer if the middle term is falsy.

```text
local a = getX()
local b = getY()
local c = true
local d = c and a or b
```

With a ternary operator, you would always expect `d` to equal `a`, but if `getX()` returns `nil`, then the `and` becomes `true and nil`, which evaluates to `nil`, and then `nil or b` evaluates to `b`.

### if-then-else expressions

We now have `if` expressions that can replace this pattern with a safer and more readable alternative. It's even faster to boot.

```text
local a = getX()
local b = getY()
local c = true
local d = if c then a else b  -- No problem if a is falsy.
```

## Arrays

Arrays in Lua are effectively tables with numerical indices, and the length operator `#` only counts the contiguous numerical indices starting with 1. This applies to the `ipairs` iterator function as well.

```text
local a = {
    0 = "not counted",
    1 = "counted",
    2 = "counted",
    3 = "counted",
    5 = "not counted",
    X = "not counted",
}
local n = #a  -- 3
for k, v in ipairs(a) do
    print(k, v)  -- Prints the three "counted" values
end
```

### Length and Sparse Arrays

Don't count on the length operator to correctly count the contiguous portion of a sparse array. Internally, it does a binary search to calculate the length, and sometimes sparse arrays can give unexpected results.

If you need to know the length of a sparse array, you will need to keep track of it yourself. Use the same pattern that `table.pack` does and store the length in `yourSparseArray.n`.

### Nil Values

Because setting a table value to nil removes that key, nil values in arrays can throw off the expected length.

```text
local a = {1, 2, 3, 4, 5}
a[4] = getSomething()  -- happens to return nil
local n = #a  -- 3
```

### 1-Based Index Math

Remember that Lua indices start at 1 if you are doing math on indices. For example, the first index in a list will not be zero mod 2, and when wrapping a large number into an index, you need to add 1 after modding.

## Return Values

### Returning Nothing

There is a difference between returning `nil` and returning nothing, but it is not always obvious.

```text
local function zero()
    return
end

local function one()
    return nil
end

local a = {1}
table.insert(a, one())  -- Inserting nil leaves a unchanged
table.insert(a, zero())  -- Error! wrong number of arguments to 'insert'
```

Make sure if your function ever returns any value, even `nil`, every return in your function returns some value, at least `nil`.

### Returning multiple values

Lua functions can return multiple values, but the extra values can be lost in some slightly unexpected situations. In particular, only the last function in a list will be expanded. All others will only retain their first output.

```text
local function values(n)
    if n == 1 then
        return 1
    elseif n == 2 then
        return 1, 2
    else
        return 1, 2, 3
    end
end

print(values(2))  -- 1 2
print(values(1), values(2))  -- 1 1 2
print(values(3), values(2))  -- 1 1 2 (!)
print(values(3), values(2), 1)  -- 1 1 1 (!)
```

A more realistic example of where this might come up is in a function that uses default values:

```text
local function position(x, y, z)
    z = z or 0  -- default z to 0
    -- ...
end

position(getX(), getY())
```

If `getY` returns a second value some of the time, this can unintentionally change `z`.

### Forcing a Single Return

Both of the above problems are frequently hidden because there are several situations where Lua will force the results into one value.

-   Putting parentheses around an expression will force exactly one value, either the first if there are multiple, or `nil` if there were zero.
-   Assigning to a list of variables will force each variable to take a value, filling in the extras with `nil`.
-   As mentioned above, only the last set of values in a sequence of arguments will be expanded. Anything before that will be reduced to a single value.

## Roblox Types as Table Keys

Instances are the only Roblox type that are safe to use as a table key. Even then, instances should never be used as keys in a _weak_ table as their collection semantics are unintuitive and not useful.
#5.1 List

# Add an item to the end of the list. Equivalent to a[len(a):] = [x]
list.append(x)
	>>> stack = ['a','b']
	>>> stack.append('c')
	>>> stack
	['a', 'b', 'c']
	>>> stack.append(['e','f'])
	>>> stack
	['a', 'b', 'c', ['e', 'f']]

	>>> squares = []
	>>> for x in range(10):
	...     squares.append(x**2)
	...
	>>> squares
	[0, 1, 4, 9, 16, 25, 36, 49, 64, 81]

# Extend the list by appending all the items from the iterable. Equivalent to a[len(a):] = iterable
list.extend(iterable)
	>>> stack.append('c')
	>>> stack
	['a', 'b', 'c']
	>>> stack.extend(['e','f'])
	>>> stack
	['a', 'b', 'c', 'e', 'f']

# Insert an item at a given position. 
# The first argument is the index of the element before which to insert, 
# so a.insert(0, x) inserts at the front of the list, and a.insert(len(a), x) is equivalent to a.append(x)
list.insert(i,x)
	>>> stack.insert(2,'z')
	>>> stack
	['a', 'b', 'z', 'c', 'e', 'f']
	# 0    1    2

# Remove the first item from the list whose value is x. It is an error if there is no such item.
list.remove(x)
	>>> stack = ['a','b','a']
	>>> stack.remove('a')
	>>> stack
	['b', 'a']
	>>> stack.remove('c')
	Traceback (most recent call last):
	  File "<stdin>", line 1, in <module>
	ValueError: list.remove(x): x not in list

# Remove the item at a specific index
del list[i]
del list[i:]

# Remove the item at the given position in the list, and return it. If no index is specified, a.pop() removes and returns the last item in the list.
list.pop([i])
	>>> stack = ['a','b','c']
	>>> stack.pop(0)
	'a'
	>>> stack
	['b', 'c']
	>>> stack.pop()
	'c'
	>>> stack
	['b']

#Remove all items from the list. Equivalent to del a[:] => []
list.clear()

# Return zero-based index in the list of the first item whose value is equal to x. Raises a ValueError if there is no such item.
# The optional arguments start and end are interpreted as in the slice notation and are used to limit the search to a particular subsequence of the list. 
# The returned index is computed relative to the beginning of the full sequence rather than the start argument.
list.index(x[, start[, end]])
	>>> stack = ['a','b','c']
	>>> stack.index('a')
	0
	>>> stack.index('a',0)
	0
	>>> stack.index('a',1)
	Traceback (most recent call last):
	  File "<stdin>", line 1, in <module>
	ValueError: 'a' is not in list
	>>> stack.index('a',0,2)
	0

# Return the number of times x appears in the list
list.count(x)

# Sort the items of the list in place (the arguments can be used for sort customization, see sorted() for their explanation).
list.sort(key=myFunc,reverse=False)
	>>> stack.sort()
	>>> stack.sort(reverse=True)
	# A function that returns the length of the value:
	def myFunc(e):
		return len(e)
	>>> cars = ['Ford', 'Mitsubishi', 'BMW', 'VW']
	>>> cars.sort(key=myFunc)

# Reverse the elements of the list in place
list.reverse()
	>>> stack
	['a', 'b', 'c']
	>>> stack.reverse()
	>>> stack
	['c', 'b', 'a']

# Return a shallow copy of the list. Equivalent to a[:]
# With new_list = my_list, you don't actually have two lists. 
# The assignment just copies the reference to the list, not the actual list, so both new_list and my_list refer to the same list after the assignment.
list.copy()
	>>> new_list = old_list.copy()

# 5.1.3. List Comprehensions
>>> squares = []
>>> for x in range(10):
...     squares.append(x**2)
...
>>> squares
[0, 1, 4, 9, 16, 25, 36, 49, 64, 81]

squares = list(map(lambda x: x**2, range(10)))

squares = [x**2 for x in range(10)]

>>> [(x, y) for x in [1,2,3] for y in [3,1,4] if x != y]
[(1, 3), (1, 4), (2, 3), (2, 1), (2, 4), (3, 1), (3, 4)]

>>> combs = []
>>> for x in [1,2,3]:
...     for y in [3,1,4]:
...         if x != y:
...             combs.append((x, y))
...
>>> combs
[(1, 3), (1, 4), (2, 3), (2, 1), (2, 4), (3, 1), (3, 4)]






########## DICT
# add item to dictionay
d[key] = value

# print value based on key
>>> tel['jack']
4098

# print key based on value
>>> for name, amount in tel.items():
...     if amount == 4098:
...             print (name)
...
jack

# print ALL
>>> for a,b in tel.items():
...     print(a,b)
...
sape 4139
>>>
>>> for a in tel.keys():
...     print(a)
...
sape
>>> for a in tel.values():
...     print(a)
...
4139

# delete from dict based on key
>>> del tel['jack']

>>> hand = {'a': 0, 'i': 0, 'm': 1, 'l': 1, 'q': 0, 'u': 0}
>>> { k:v for k,v in hand.items() if v}
{'m': 1, 'l': 1}



# returns a list of all the keys used in the dictionary
list(d)
sorted(d)

# To check whether a single key is in the dictionary, use the in keyword.
>>> 'guido' in tel
True
>>> 'jack' not in tel
False



# When looping through a sequence, the position index and corresponding value can be retrieved at the same time using the enumerate() function.
>>> for i, v in enumerate(['tic', 'tac', 'toe']):
...     print(i,v)
...
0 tic
1 tac
2 toe












# LOOP 
>>> for i in reversed(range(1,10,2)):
...     print(i)
...
9
7
5
3
1
import string
import random

random.seed(0)

minDigits = 1
maxDigits = 4

def number():
  return "".join([random.choice(string.digits) for _ in range(random.randint(minDigits,maxDigits))])

minWord = 5
maxWord = 10
def word():
  return "".join([random.choice(string.ascii_letters) for _ in range(random.randint(minWord,maxWord))])

minDice = 1
maxDice = 4
def roll():
  die = []
  for _ in range(random.randint(minDice, maxDice)):
    roll = ""
    if random.randint(0,1) == 1:
      roll += number()
      
    if random.randint(0,1) == 1:
      roll += "d" + number()
    else:
      roll += "D" + number()
      
    die.append(roll)
  return "+".join(die)


line_num = 2000
things_per_line = 10

lines = []
for _ in range(line_num):
  line = []
  for _ in range(things_per_line):
    if random.randint(0,1) == 1:
      line.append(word())
    else:
      line.append(roll())
  lines.append(" ".join(line))

print("\n".join(lines))

def get_int_input(prompt="", condition = lambda x: True, condition_fail_text = "Please input a number that satisfies criteria"):
    while True:
        value = 0
        try:
            value = int(input(prompt))
        except KeyboardInterrupt:
            exit()
        except:
            print("Please input a valid number")
            continue

        if condition(value):
            break

        # invalid condition
        print(condition_fail_text)
    return value

print("*"*10, "   Call break calculator   ", "*"*10, '\n')
# ask all 4 players names
names = []
for _ in range(4):
    names.append(input(f"Please tell the name of player {_+1} : "))
print(f"\nPlayers are:\n", *names,'\n' ,sep='\t')

points = []
total = [[0,0] for _ in range(4)]

for i in range(5): # five games
    targets = [1 for _ in range(4)] # kati haat bolne

    print(f"\nGame {i+1}")
    for index in range(4): # 4 players
        player_index = (i+index) % 4
        target = get_int_input(
            prompt=f"Please input target for {names[player_index]} = ", 
            condition=lambda x : 1 <= x <= 13, 
            condition_fail_text="Please input a number between 1 and 13 (inclusive)."
        )
        targets[player_index] = target
    
    this_game_points = [0 for _ in range(4)]
    for index in range(4): # 4 players
        player_index = (i+index)  % 4
        target = targets[player_index]
        hands_won = get_int_input(
            prompt = f"Please input number of hands won by {names[player_index]} = ",
            condition=lambda x : 0 <= x <= 13, 
            condition_fail_text="Pleaes input valid number of hands"
        )

        if hands_won < target:
            total[player_index][0] -= target # reduced
            this_game_points[player_index] = [f"({target})", ""]
        else:
            total[player_index][0] += target # points increased
            total[player_index][1] += hands_won-target # additional oti's
            this_game_points[player_index] = [f"{target}", f"{hands_won - target}"]
    points.append(this_game_points)
    
    # display points
    print(f"\nS.N.", *names, sep='\t')
    for j in range(i+1):
        print(f"{j+1}.", *[f"{points[j][p][0]}.{points[j][p][1]}" for p in range(4)],sep = '\t')
    print("-"*40)
    print(f"Total", *[f"{total[p][0]}.{total[p][1]}" for p in range(4)], sep='\t')
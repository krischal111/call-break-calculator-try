use std::io::{self, Write};
use std::process;

fn get_int_input<F>(prompt: &str, condition: F, condition_fail_text: &str) -> i32 
where F: Fn(i32) -> bool {
    loop {
        print!("{}", prompt);
        io::stdout().flush().unwrap();
        
        let mut input = String::new();
        match io::stdin().read_line(&mut input) {
            Ok(_) => {
                match input.trim().parse::<i32>() {
                    Ok(value) => {
                        if condition(value) {
                            return value;
                        } else {
                            println!("{}", condition_fail_text);
                        }
                    },
                    Err(_) => println!("Please input a valid number"),
                }
            },
            Err(_) => {
                println!("Error reading input");
                process::exit(1);
            }
        }
    }
}

fn main() {
    println!("{}   Call Break Calculator   {}\n", "*".repeat(10), "*".repeat(10));
    
    // Ask all 4 players names
    let mut names = Vec::with_capacity(4);
    for i in 0..4 {
        print!("Please tell the name of player {} : ", i + 1);
        io::stdout().flush().unwrap();
        let mut name = String::new();
        io::stdin().read_line(&mut name).unwrap();
        names.push(name.trim().to_string());
    }
    
    println!("\nPlayers are:");
    for name in &names {
        print!("\t{}", name);
    }
    println!("\n");
    
    let mut total = vec![[0, 0]; 4];
    let mut points = Vec::new();
    
    for game in 0..5 {
        let mut targets = vec![1; 4];
        println!("\nGame {}", game + 1);
        
        // Get targets
        for index in 0..4 {
            let player_index = (game + index) % 4;
            let target = get_int_input(
                &format!("Please input target for {} = ", names[player_index]),
                |x| 1 <= x && x <= 13,
                "Please input a number between 1 and 13 (inclusive)."
            );
            targets[player_index] = target;
        }
        
        let mut this_game_points = vec![[String::new(), String::new()]; 4];
        
        // Get hands won
        for index in 0..4 {
            let player_index = (game + index) % 4;
            let target = targets[player_index];
            let hands_won = get_int_input(
                &format!("Please input number of hands won by {} = ", names[player_index]),
                |x| 1 <= x && x <= 13,
                "Please input valid number of hands"
            );
            
            if hands_won < target {
                total[player_index][0] -= target;
                this_game_points[player_index] = [format!("({})", target), String::new()];
            } else {
                total[player_index][0] += target;
                total[player_index][1] += hands_won - target;
                this_game_points[player_index] = [target.to_string(), (hands_won - target).to_string()];
            }
        }
        points.push(this_game_points);
        
        // Display points
        print!("\nS.N.");
        for name in &names {
            print!("\t{}", name);
        }
        println!();
        
        for j in 0..=game {
            print!("{}.", j + 1);
            for p in 0..4 {
                print!("\t{}.{}", points[j][p][0], points[j][p][1]);
            }
            println!();
        }
        
        println!("{}", "-".repeat(40));
        print!("Total");
        for p in 0..4 {
            print!("\t{}.{}", total[p][0], total[p][1]);
        }
        println!();
    }
}
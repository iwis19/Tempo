# Learnings

everything ive learned in this project


## Overview

begins here


### Timer

#### Making a timer

Syntax:
    let timer = Timer.publish(every: seconds, on: .main, in: .common).autoconnect()

Explanation: 
    - timer is always a combine publisher object that emits events over time
    
#### Working with timer

Syntax:
    .onReceive(timer) { value in
        //code
    }
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 1){
        //code
    }
}
    
Explanation:
    - in .onReceive(timer), it receives a signal to act on it
    - in value in, value can be replaced by _ if you do not care about the inputs
    - in DispatchQueue, it essentially means run this code on main thread, but later
    - DispatchQueue is apple's method of scheduling work, .asyncAfter means do this asynchronously after a delay, and deadline: .now() + 1 means do it 1 second from now
    

### Lists

Syntax: 
    let subtitles = ["item1", "item2", "item3"]
    let length = subtitles.count
    Text(subtitles[2])
    
Explanation:
    - syntax for creating lists is a lot like other languages
    - .count gives the length of a list
    - to access the item of a list, use the index
    
    
### Animations

#### With Animation

Syntax: 
    withAnimaton(//animation style){
        //code
    }

Explanation:
    - makes the program have animations if the code within the curly brackets lead to any ui updates



module MyModule::Reward {
    use std::signer;
    use std::vector;
    use aptos_framework::coin;
    use aptos_framework::aptos_coin::AptosCoin;
    use aptos_framework::account;

    struct Course has key, store {
        total_enrolled: u64,
        completion_reward: u64,
        course_creator: address,
        enrolled_students: vector<address>
    }

    struct RewardClaimRequest has key, store {
        student: address,
        course_creator: address
    }

    /// **Function to create a course**
    public entry fun create_course(
        course_creator: &signer, 
        completion_reward: u64
    ) {
        let creator_addr = signer::address_of(course_creator);

        // Ensure the creator has an AptosCoin account
        if (!coin::is_account_registered<AptosCoin>(creator_addr)) {
            coin::register<AptosCoin>(course_creator);
        };

        let course = Course {
            total_enrolled: 0,
            completion_reward,
            course_creator: creator_addr,
            enrolled_students: vector::empty<address>()
        };
        move_to(course_creator, course);
    }

    /// **Function to enroll a student in a course**
    public entry fun enroll(
        student: &signer, 
        course_creator: address
    ) acquires Course {
        let course = borrow_global_mut<Course>(course_creator);
        vector::push_back(&mut course.enrolled_students, signer::address_of(student));
        course.total_enrolled = course.total_enrolled + 1;
    }

    /// **Function for students to request a course completion reward**
    public entry fun request_course_completion_reward(
        student: &signer, 
        course_creator: address
    ) {
        let student_addr = signer::address_of(student);

        // Ensure the student is registered for AptosCoin before requesting
        assert!(coin::is_account_registered<AptosCoin>(student_addr), 101);

        let request = RewardClaimRequest {
            student: student_addr,
            course_creator
        };
        move_to(student, request);
    }

    /// **Function for course creators to approve & transfer reward**
    public entry fun approve_and_transfer_reward(
        course_creator: &signer, 
        student: address
    ) acquires Course {
        // Ensure the student has an AptosCoin account before transferring rewards
        assert!(coin::is_account_registered<AptosCoin>(student), 102);

        let course_addr = signer::address_of(course_creator);
        let course = borrow_global_mut<Course>(course_addr);
        let amount = course.completion_reward;

        // Transfer reward from course creator to student
        coin::transfer<AptosCoin>(course_creator, student, amount);
    }

    /// **Function to get the total number of students enrolled in a course**
    public fun get_course_enrolled(course_creator: &signer): u64 acquires Course {
        let course_addr = signer::address_of(course_creator);
        let course = borrow_global<Course>(course_addr);
        course.total_enrolled
    }
}

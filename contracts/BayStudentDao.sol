pragma solidity >=0.8.0;

import "./BayToken.sol";

contract BayStudentDao is BayToken {

    uint8 INIT_VOTE_SCORE = 255;

    struct Lesson {
        address tutor_wallet_address;
        uint entry_fee;
        address[] participants;     
        uint8[] votes; 
        bool status;
    }

    uint lesson_id = 1;

    mapping (uint => Lesson) public lessons;

    function create_lesson(address _tutor_wallet_address, uint _entry_fee) external onlyOwner {
        Lesson memory _lesson;
        _lesson.tutor_wallet_address = _tutor_wallet_address;
        _lesson.entry_fee = _entry_fee;
        _lesson.status = true;
        lessons[lesson_id] = _lesson;
        lesson_id++;
    }

    function participate_lesson(uint _lesson_id) public {
        require(_lesson_id < lesson_id, "Invalid lesson id");
        require(lessons[_lesson_id].status == true, "The lesson is closed");
        require(balanceOf(msg.sender) > lessons[_lesson_id].entry_fee, "Not enough balance to pay the entry fee");
        for (uint i; i < lessons[_lesson_id].participants.length; i++) {
            if (lessons[_lesson_id].participants[i] == msg.sender) {
            revert("Already participated the lesson"); 
            }
        }
        transfer(owner(), lessons[_lesson_id].entry_fee);
        lessons[_lesson_id].participants.push(msg.sender);
        lessons[_lesson_id].votes.push(INIT_VOTE_SCORE);
    }

    function close_lesson(uint _lesson_id) external onlyOwner {
        require(_lesson_id < lesson_id, "Invalid lesson id");
        lessons[_lesson_id].status = false;
    }

    function vote_lesson(uint _lesson_id, uint8 _score) public {
        require(_lesson_id < lesson_id, "Invalid lesson id");
        require(_score <= 10, "Invalid score");
        require(lessons[_lesson_id].status == false, "The lesson is not over yet");
        
        for (uint i; i < lessons[_lesson_id].participants.length; i++) {
            if (lessons[_lesson_id].participants[i] == msg.sender && lessons[_lesson_id].votes[i] == INIT_VOTE_SCORE) {
            lessons[_lesson_id].votes[i] = _score;
            }
        }
        revert("You don't have the right to vote / or you already voted");
    }

    function calculate_incentive_for_tutor(uint256 _mean_score, uint256 _total_entry_fee) public pure returns (uint256){
        if(_mean_score <= 3 * 10 ** 18){
            return _mean_score  * 10 / 3 / (10**2) * _total_entry_fee / (10**18);
        }
        else if(_mean_score <= 7 * 10 ** 18){
            return (_mean_score - 10**18) * 5 / (10**2) * _total_entry_fee / (10**18);
        }
        else{
            return (_mean_score + 2*10**18) * 10 / 3 / (10**2) * _total_entry_fee / (10**18);
        }
    }
    function calculate_share_for_voter(uint _vote_score, uint256 _mean_score) public pure returns (uint256){
        int256 x = int256(_vote_score*10**18) - int256(_mean_score);
        int256 value = ( ( (x**2) / (10**18) ) * (-6) / 10 + 8 * (10**18) / 10 );
        if(value > 0){
            return uint256(value);
        }
        else{
            return 0;
        }
    }

    function calculate_incentive_for_voter(uint256 share, uint256 total_share, uint256 _total_entry_fee) public pure returns (uint256){
        return _total_entry_fee * share / total_share;
    }

    function distribute_incentives(uint _lesson_id) external onlyOwner {
        require(_lesson_id < lesson_id, "Invalid lesson id");

        uint256 _total_score = 0;

        for (uint i; i < lessons[_lesson_id].participants.length; i++) {
            if (lessons[_lesson_id].votes[i] != INIT_VOTE_SCORE){
                _total_score += lessons[_lesson_id].votes[i] * 10**18; // 평균 점수 소수점 18자리까지 표현 
            }
        }

        uint256 _total_entry_fee = lessons[_lesson_id].participants.length * lessons[_lesson_id].entry_fee;

        uint256 _mean_score = _total_score / lessons[_lesson_id].participants.length;

        transfer(lessons[_lesson_id].tutor_wallet_address, calculate_incentive_for_tutor(_mean_score,_total_entry_fee));

        uint256 _total_share = 0;

        for (uint i; i < lessons[_lesson_id].participants.length; i++) {
            if (lessons[_lesson_id].votes[i] != INIT_VOTE_SCORE){
                _total_share += calculate_share_for_voter(lessons[_lesson_id].votes[i], _mean_score);
            }
        }
        for (uint i; i < lessons[_lesson_id].participants.length; i++) {
            if (lessons[_lesson_id].votes[i] != INIT_VOTE_SCORE){
                transfer(lessons[_lesson_id].participants[i], calculate_incentive_for_voter(calculate_share_for_voter(lessons[_lesson_id].votes[i], _mean_score), _total_share, _total_entry_fee));
            }
        }
    }
}

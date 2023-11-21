function checkUserInputs(userInput,index)
% Check if the user input is valid

    % input: user input
    % index: which test to perform
    
if ~isnumeric(index) || ~ismember(index, [1:7])
   error('Please insert an index between 1-7') 
end
    

switch index
    case 1
        if ~all(isnumeric(userInput)) || ~ismember(all(userInput), [1:64])
            error('Please insert channels between 1-64') 
        end
    case 2
        if ~all(isnumeric(userInput)) || ~all(userInput > 0) || ~all(mod(userInput,1) == 0)
            error('Please insert integers greater than zero') 
        end
    case 3
        if mod(userInput, 2) ~= 0 || ~isnumeric(userInput) || userInput <= 0
            error('Please insert an even number greater than zero')
        end
    case 4
        if ~all(islogical(userInput))
            error('Not all user inputs are boolean')       
        end
        
    case 5
        while (~isnumeric(userInput) || ~ismember(userInput, [1, 2, 3, 4])) && userInput ~= 5
            userInput = input('Error: Please insert only the values (1, 2, 3 or 4) or exit (5): ');
            if userInput == 5
                return;
            end
        end
        disp('----------------------------------------------------------------')
        switch userInput
            case 1
                disp('Choise: Candidate and reference subjects from "MainBaseline.m"')
            case 2
                disp('Choise: Custom reference and candidate subjects')
            case 3
                disp('Use 17 reference subjects for each candidate subject')
        end
      
        
    case 6
        if ~all(userInput{1} >= 1 & userInput{1} <= 18) || ~all(userInput{2} >= 1 & userInput{2} <= 18)
            error('Please insert one or more integers between 1-18') 
        end
        
        if numel(unique(userInput{1})) ~= numel(userInput{1}) || numel(unique(userInput{2})) ~= numel(userInput{2})
            error('Please insert unique values between 1-18 in each vector')
        end
        
        if ~all(mod(userInput{1}, 1) == 0) || ~all(mod(userInput{2}, 1) == 0)
            error('Please insert one or more integers between 1-18');
        end
end
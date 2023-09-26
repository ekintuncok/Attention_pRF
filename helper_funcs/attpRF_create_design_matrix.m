function stim_index = attpRF_create_design_matrix(designFolder, event_type, currentMatrix, currentIter)

switch designFolder
    case '01'
        for ind = 1:length(event_type)
            if event_type(ind) == 1
                stim_index(ind)      = 0;
            elseif event_type(ind) == 2
                stim_index(ind)       = 0;
            elseif event_type(ind) == 3
                conditionNumber = currentMatrix(currentIter,4);
                mappingStimInd = currentMatrix(currentIter,3);
                %                 indexes the mapping stim only if the current trial
                %                 had the given precue
                if mappingStimInd < 49
                    if conditionNumber ~= 1
                        stim_index(ind) = 48 * (conditionNumber-1) + mappingStimInd;
                    else
                        stim_index(ind) =  mappingStimInd;
                    end
                else
                    stim_index(ind) = 241;
                end
                fprintf('condition = %g, mapping code = %g\n', conditionNumber,stim_index(ind))
            elseif event_type(ind) == 4
                stim_index(ind)       = 0;
            elseif event_type(ind) == 5
                stim_index(ind)   = 0;
            elseif event_type(ind) == 6
                stim_index(ind)       = 0;
            elseif event_type(ind) == 7
                stim_index(ind)       = 0;
                if currentIter ~= 52
                    currentIter = currentIter+1;
                end
            end
        end

    case '03'

        for ind = 1:length(event_type)

            if event_type(ind) == 1
                stim_index(ind)      = 0;
            elseif event_type(ind) == 2
                stim_index(ind)       = 0;
            elseif event_type(ind) == 3
                conditionNumber = currentMatrix(currentIter,4);
                mappingStimInd = currentMatrix(currentIter,3);
                %                 indexes the mapping stim only if the current trial
                %                 had the given precue
                if mappingStimInd < 49
                    if conditionNumber ~= 1
                        stim_index(ind) = 48 * (conditionNumber-1) + mappingStimInd;
                    else
                        stim_index(ind) =  mappingStimInd;
                    end
                else
                    if conditionNumber == 1
                        stim_index(ind) = 241;
                    elseif conditionNumber == 2
                        stim_index(ind) = 242;
                    elseif conditionNumber == 3
                        stim_index(ind) = 243;
                    elseif conditionNumber == 4
                        stim_index(ind) = 244;
                    elseif conditionNumber == 5
                        stim_index(ind) = 245;
                    end
                end
                fprintf('condition = %g, mapping code = %g\n', conditionNumber,stim_index(ind))
            elseif event_type(ind) == 4
                stim_index(ind)       = 0;
            elseif event_type(ind) == 5
                stim_index(ind)   = 0;
            elseif event_type(ind) == 6
                stim_index(ind) = 0;
            elseif event_type(ind) == 7
                stim_index(ind)       = 0;
                if currentIter ~= 52
                    currentIter = currentIter+1;
                end
            elseif event_type(ind) == 8
                stim_index(ind)       = 0;
            end
        end


    case '04'

        for ind = 1:length(event_type)
            if event_type(ind) == 1
                stim_index(ind)      = 0;
            elseif event_type(ind) == 2
                stim_index(ind)       = 0;
            elseif event_type(ind) == 3
                conditionNumber = currentMatrix(currentIter,4);
                mappingStimInd = currentMatrix(currentIter,3);
                %                 indexes the mapping stim only if the current trial
                %                 had the given precue
                if mappingStimInd < 49
                    if conditionNumber ~= 1
                        stim_index(ind) = 48 * (conditionNumber-1) + mappingStimInd;
                    else
                        stim_index(ind) =  mappingStimInd;
                    end
                else
                    stim_index(ind) = 241;
                end
                fprintf('condition = %g, mapping code = %g\n', conditionNumber,stim_index(ind))
            elseif event_type(ind) == 4
                stim_index(ind)       = 0;
            elseif event_type(ind) == 5
                stim_index(ind)   = 0;
            elseif event_type(ind) == 6
                if conditionNumber == 1
                    stim_index(ind) = 242;
                elseif conditionNumber == 2
                    stim_index(ind) = 243;
                elseif conditionNumber == 3
                    stim_index(ind) = 244;
                elseif conditionNumber == 4
                    stim_index(ind) = 245;
                elseif conditionNumber == 5
                    stim_index(ind) = 246;
                end
            elseif event_type(ind) == 7
                stim_index(ind)       = 0;
                if currentIter ~= 52
                    currentIter = currentIter+1;
                end
            elseif event_type(ind) == 8
                stim_index(ind)       = 0;
            end
        end
    case '05'

        for ind = 1:length(event_type)

            if event_type(ind) == 1
                stim_index(ind)      = 0;
            elseif event_type(ind) == 2
                stim_index(ind)       = 0;
            elseif event_type(ind) == 3
                conditionNumber = currentMatrix(currentIter,4);
                mappingStimInd = currentMatrix(currentIter,3);
                %                 indexes the mapping stim only if the current trial
                %                 had the given precue
                if mappingStimInd < 49
                    if conditionNumber ~= 1
                        stim_index(ind) = 48 * (conditionNumber-1) + mappingStimInd;
                    else
                        stim_index(ind) =  mappingStimInd;
                    end
                else
                    if conditionNumber == 1
                        stim_index(ind) = 241;
                    elseif conditionNumber == 2
                        stim_index(ind) = 242;
                    elseif conditionNumber == 3
                        stim_index(ind) = 243;
                    elseif conditionNumber == 4
                        stim_index(ind) = 244;
                    elseif conditionNumber == 5
                        stim_index(ind) = 245;
                    end
                end
                fprintf('condition = %g, mapping code = %g\n', conditionNumber,stim_index(ind))
            elseif event_type(ind) == 4
                stim_index(ind)       = 0;
            elseif event_type(ind) == 5
                stim_index(ind)   = 0;
            elseif event_type(ind) == 6
                if conditionNumber == 1
                    stim_index(ind) = 246;
                elseif conditionNumber == 2
                    stim_index(ind) = 247;
                elseif conditionNumber == 3
                    stim_index(ind) = 248;
                elseif conditionNumber == 4
                    stim_index(ind) = 249;
                elseif conditionNumber == 5
                    stim_index(ind) = 250;
                end
            elseif event_type(ind) == 7
                stim_index(ind)       = 0;
                if currentIter ~= 52
                    currentIter = currentIter+1;
                end
            elseif event_type(ind) == 8
                stim_index(ind)       = 0;
            end
        end

    case '10'
     fprintf('>>> design matrix prepped for glmsingle \n')
        for ind = 1:length(event_type)

            if event_type(ind) == 1
                stim_index(ind)      = 0;
            elseif event_type(ind) == 2
                stim_index(ind)       = 0;
            elseif event_type(ind) == 3
                conditionNumber = currentMatrix(currentIter,4);
                mappingStimInd = currentMatrix(currentIter,3);
                %                 indexes the mapping stim only if the current trial
                %                 had the given precue
                if mappingStimInd < 49
                    stim_index(ind) =  mappingStimInd;
                else
                    stim_index(ind) =  49;
                end
                fprintf('condition = %g, mapping code = %g\n', conditionNumber,stim_index(ind))
            elseif event_type(ind) == 4
                stim_index(ind)       = 0;
            elseif event_type(ind) == 5
                stim_index(ind)   = 0;
            elseif event_type(ind) == 6
                stim_index(ind) = 50;
            elseif event_type(ind) == 7
                stim_index(ind)       = 0;
                if currentIter ~= 52
                    currentIter = currentIter+1;
                end
            elseif event_type(ind) == 8
                stim_index(ind)       = 0;
            end
        end
end



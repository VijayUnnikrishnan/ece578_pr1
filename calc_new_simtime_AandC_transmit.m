function [i, BKP_CNT_A, BKP_CNT_C, coll_det, A_tran_suc, C_tran_suc, CW_A, CW_C, A_backedup, C_backedup] = calc_new_simtime_AandC_transmit(i, vcs_en, hidterminal, A_backedup, C_backedup, CW_A, CW_C , DataSlot, BKP_CNT_A, BKP_CNT_C, X_A_pkt_arr_time, X_C_pkt_arr_time, A_tidx, C_tidx )
%BKP_CNT_A = CW_A;
%BKP_CNT_C = CW_C;
coll_det  = 0;
A_tran_suc = 0;
C_tran_suc = 0;

CWMAX_C = 1024;
CWMAX_A = 1024;
CWMIN_C = 4;
CWMIN_A = 4;

if (A_backedup)
    BKP_CNT_A = BKP_CNT_A;  %Continue from previous value if A was backed up earlier
else
    BKP_CNT_A = (randi((CW_A), 1,1)) - 1;
end

if (C_backedup)
    BKP_CNT_C = BKP_CNT_C;
else
    BKP_CNT_C = (randi((CW_C), 1,1)) - 1;
end

if(hidterminal)
    if (vcs_en)
        if((BKP_CNT_A + 2 + 1 + 2) < BKP_CNT_C )
            i = i + BKP_CNT_A + 2 + 1 + 2 + 1 + DataSlot + 1 + 2 ;  % Proceed the timeslot by BAKUP+ RTS + SIFS + CTS
            BKP_CNT_C = BKP_CNT_C - (BKP_CNT_A + 2 + 1);                % A is successful and C is backed
            C_backedup = 1;
            A_backedup = 0;
            A_tran_suc = 1;
            CW_A = CWMIN_A;
              %fprintf("Mode 4:  A success   %d, %d  %d\n", BKP_CNT_A, BKP_CNT_C,i); 
            if (CW_C < CWMAX_C) CW_C = 2*CW_C; end
             %fprintf("Mode 4:  A success   %d, %d  %d\n", BKP_CNT_A, BKP_CNT_C,i); 
        elseif ((BKP_CNT_C + 2 + 1 + 2) < BKP_CNT_A)
            i = i + BKP_CNT_C + 2 + 1 + 2 + 1 + DataSlot + 1 + 2 ;  % Proceed the timeslot by BAKUP+ RTS + SIFS + CTS
            BKP_CNT_A = BKP_CNT_A - (BKP_CNT_C + 1 + 2 + 1 );                % C is successfull and A is backed
            C_tran_suc = 1;
            C_backedup = 0;
            A_backedup = 1;
            CW_C = CWMIN_C;
             %fprintf("Mode 4:  C success   %d, %d  %d\n", BKP_CNT_A, BKP_CNT_C,i); 
            if (CW_A < CWMAX_A) CW_A = 2*CW_A; end
        else
            coll_det = 1;
            %fprintf("Mode 4: Detected Collison when both nodes try with data in hidden mode  %d, %d  %d, %d, %d\n", CW_C, CW_A, BKP_CNT_A, BKP_CNT_C,i); 
            i = i + (max(BKP_CNT_A, BKP_CNT_C)) + 2 + 1 + 2;       % Collison ofr RTS + CTS window
            if (CW_C < CWMAX_C) CW_C = 2*CW_C; end
            if (CW_A < CWMAX_A) CW_A = 2*CW_A; end
           % fprintf("Collision Detected. %f, %f %f %f \n" , CW_A, CW_C, BKP_CNT_A, BKP_CNT_C);
        end
    else
        if((BKP_CNT_A +  DataSlot + 1 + 2) < BKP_CNT_C)
            i = i + BKP_CNT_A + DataSlot + 1 + 2 ;                 % Proceed the timeslot by BAKUP+ RTS + SIFS + CTS
            BKP_CNT_C = BKP_CNT_C - (BKP_CNT_A + 1 + DataSlot + 1 );                % A is successful and C is backed
            A_tran_suc = 1;
            C_backedup = 1;
            A_backedup = 0;
            CW_A = CWMIN_A;
            %fprintf("Mode 3:  A success   %d, %d  %d\n", BKP_CNT_A, BKP_CNT_C,i); 
            if (CW_C < CWMAX_C) CW_C = 2*CW_C; end
        elseif ((BKP_CNT_C +  DataSlot + 1 + 2) < BKP_CNT_A)
            i = i + BKP_CNT_C + DataSlot + 1 + 2 ;  % Proceed the timeslot by BAKUP+ RTS + SIFS + CTS
            BKP_CNT_A = BKP_CNT_A - (BKP_CNT_C + 1 + DataSlot + 1);                % C is successfull and A is backed
            C_tran_suc = 1;
            C_backedup = 0;
            A_backedup = 1;
            CW_C = CWMIN_C;
            %fprintf("Mode 3:  C success   %d, %d  %d\n", BKP_CNT_A, BKP_CNT_C,i); 
            if (CW_A < CWMAX_A) CW_A = 2*CW_A; end
        else
            coll_det = 1;
            %fprintf(" Mode 3: Detected Collison when both nodes try with data in hidden mode  %d, %d  %d, %d, %f\n", CW_C, CW_A, BKP_CNT_A, BKP_CNT_C, i);
            i = i + (max(BKP_CNT_A, BKP_CNT_C)) + DataSlot + 1 + 2 ;       % Collison ofr RTS + CTS window
            if (CW_C < CWMAX_C) CW_C = 2*CW_C; end
            if (CW_A < CWMAX_A) CW_A = 2*CW_A; end
            A_backedup = 0;
            C_backedup = 0;
        end
    end
else

    if (BKP_CNT_C == BKP_CNT_A)
        %if true part
        %fprintf("Collision detected: %f, %f \n", BKP_CNT_A , BKP_CNT_C );
        if (CW_C < CWMAX_C) CW_C = 2*CW_C; end
        if (CW_A < CWMAX_A) CW_A = 2*CW_A; end
        if (vcs_en)
            i = i + BKP_CNT_C + 2 + 1 + 2;  % Proceed the timeslot by BAKUP+ RTS + SIFS + CTS
        else
            i = i + BKP_CNT_C + DataSlot + 2 + 1;  % Proceed the timeslot by BAKUP+ Data slot + SIFS + ACK
        end
        coll_det = 1;
        A_backedup = 0;
        C_backedup = 0;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    elseif (BKP_CNT_A < BKP_CNT_C)  %A is successful in transmission
        %fprintf("A is successful in Transmission \n" );
        %bkoff_diffAC = BKP_CNT_C - BKP_CNT_A;
        CW_A = CWMIN_A;
        if (vcs_en)
            i = i + BKP_CNT_A + 1 + 2 + 1 + 2 + 1 + DataSlot + 1+ 2 ; %Proceed the time by BKP + RTS + SIFS + CTS + SIFS + Dataslot + SIFS + ACK
        else
            i = i + BKP_CNT_A + 1 + DataSlot + 1+ 2 ; %Proceed the time by BKP + Dataslot + SIFS + ACK
        end
        C_backedup = 1;
        A_backedup = 0;
        BKP_CNT_C = BKP_CNT_C - (BKP_CNT_A + 1);
        A_tran_suc = 1;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    elseif (BKP_CNT_C < BKP_CNT_A)  %C is successful in transmission
        %fprintf("C is successful in Transmission \n" );
        %bkoff_diffAC = BKP_CNT_C - BKP_CNT_A;
        CW_C = CWMIN_C;
        if (vcs_en)
            i = i + BKP_CNT_A + 1 + 2 + 1 + 2 + 1 + DataSlot + 1+ 2 ; %Proceed the time by BKP + RTS + SIFS + CTS + SIFS + Dataslot + SIFS + ACK
        else
            i = i + BKP_CNT_A + 1 + DataSlot + 1+ 2 ; %Proceed the time by BKP + Dataslot + SIFS + ACK
        end
        C_backedup = 0;
        A_backedup = 1;
        BKP_CNT_A = BKP_CNT_A - (BKP_CNT_C + 1);
        C_tran_suc = 1;
    end  %% End of if statement
end
%fprintf("Value of i is %d",i);
end  %% End of function

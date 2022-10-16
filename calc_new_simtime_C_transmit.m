function [i, BKP_CNT_A, BKP_CNT_C, coll_det_A, coll_det_C, A_tran_suc, C_tran_suc,CW_A, CW_C] = calc_new_simtime_C_transmit(i, sim_time, hidterminal, FrameSlot,  X_A_pkt_arr_time, A_tidx, vcs_en, A_backedup, C_backedup, CW_A, CW_C , DataSlot, BKP_CNT_A, BKP_CNT_C, DATA_RATE,dat_rt, RUNTIME)
%BKP_CNT_A = CW_A;
%BKP_CNT_C = CW_C;
coll_det_A  = 0;
coll_det_C  = 0;
A_tran_suc = 0;
C_tran_suc = 0;

CWMAX_C = 1024;
CWMAX_A = 1024;
CWMIN_C = 4;
CWMIN_A = 4;

if (C_backedup)
    BKP_CNT_C = BKP_CNT_C;  %Continue from previous value if A was backed up earlier
else
    BKP_CNT_C = (randi((CW_C), 1,1)) - 1;
end

%fprintf("NoComp:A is successful in Transmission \n" );
%bkoff_diffAC = BKP_CNT_C - BKP_CNT_A;
%CW_A = CWMIN_A;

C_backedup = 0;
A_backedup = 0;
BKP_CNT_A = BKP_CNT_A ;
BKP_CNT_C = BKP_CNT_C ; % Redundant

if(hidterminal) % && (C_tidx < (DATA_RATE(dat_rt)*RUNTIME) ))
    if (vcs_en)
        if(((i + BKP_CNT_C + 1 + 2 + 1 + 2)*0.00001) < X_A_pkt_arr_time(A_tidx ))
            C_tran_suc = 1;
            CW_C = CWMIN_C;
            i = i + BKP_CNT_C + 1 + 2 + 1 + 2 + 1 + DataSlot + 1+ 2 ;
        else
            C_tran_suc = 0;
            if (CW_C < CWMAX_C) CW_C = 2*CW_C; end
            if (CW_A < CWMAX_A) CW_A = 2*CW_A; end
            coll_det_A  = 1;
            coll_det_C  = 1;
            % fprintf("Mode3 : A in collision \n" );
            i = i + BKP_CNT_C + 1 + 2 + 1 + 2;
        end
    else
        if ((i + BKP_CNT_C + DataSlot + 1 + 2 )*0.00001 < X_A_pkt_arr_time(A_tidx))
            C_tran_suc = 1;
            CW_C = CWMIN_C;
            i = i + BKP_CNT_C + 1 + DataSlot + 1+ 2 ;
        else
            i = i + BKP_CNT_C + 1 + DataSlot + 1+ 2 ;
            if (CW_C < CWMAX_C) CW_C = 2*CW_C; end
            if (CW_A < CWMAX_A) CW_A = 2*CW_A; end
            coll_det_A  = 1;
            coll_det_C  = 1;
        end
    end
else
    C_tran_suc = 1;
    CW_C = CWMIN_C;
    %CW_A = CWMIN_A;
    if (vcs_en)
        i = i + BKP_CNT_C + 1 + 2 + 1 + 2 + 1 + DataSlot + 1+ 2 ; %Proceed the time by BKP + RTS + SIFS + CTS + SIFS + Dataslot + SIFS + ACK
    else
        i = i + BKP_CNT_C + 1 + DataSlot + 1+ 2 ; %Proceed the time by BKP + Dataslot + SIFS + ACK
    end
end
end  %% End of function
function [i, BKP_CNT_A, BKP_CNT_C, coll_det, A_tran_suc, C_tran_suc, CW_C] = calc_new_simtime_C_transmit(i, sim_time, hidterminal, FrameSlot,  X_A_pkt_arr_time, A_tidx, vcs_en, A_backedup, C_backedup, CW_A, CW_C , DataSlot, BKP_CNT_A, BKP_CNT_C, DATA_RATE,dat_rt, RUNTIME)
%BKP_CNT_A = CW_A;
%BKP_CNT_C = CW_C;
coll_det  = 0;
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

%fprintf("NoComp : C is successful in Transmission \n" );
%bkoff_diffAC = BKP_CNT_C - BKP_CNT_A;
CW_C = CWMIN_C;
if (vcs_en)
    i = i + BKP_CNT_C + 1 + 2 + 1 + 2 + 1 + DataSlot + 1+ 2 ; %Proceed the time by BKP + RTS + SIFS + CTS + SIFS + Dataslot + SIFS + ACK
else
    i = i + BKP_CNT_C + 1 + DataSlot + 1+ 2 ; %Proceed the time by BKP + Dataslot + SIFS + ACK
end
C_backedup = 0;
A_backedup = 0;
BKP_CNT_A = BKP_CNT_A ;
BKP_CNT_C = BKP_CNT_C ; % Redundant
if(hidterminal && (A_tidx < DATA_RATE(dat_rt) * RUNTIME ))
    if((sim_time + (i + BKP_CNT_C + 1 + 2 + 1 + 2 + 1 + DataSlot + 1+ 2) < X_A_pkt_arr_time(A_tidx + 1) ) && vcs_en)
        C_tran_suc = 1;
        CW_C = CWMIN_C;
    elseif ((sim_time + (i + BKP_CNT_C + 1 + 2 + 1 + 2 ) < X_A_pkt_arr_time(A_tidx + 1) ))
        C_tran_suc = 1;
        CW_C = CWMIN_C;
    else
        C_tran_suc = 0;
         if (CW_C < CWMAX_C) CW_C = 2*CW_C; end
         coll_det  = 1;
     %    fprintf("Mode3 : C in collision \n" );
    end
else
    C_tran_suc = 1;
    CW_C = CWMIN_C;
end


end  %% End of function
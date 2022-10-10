%ECE 578 CSMA CD without Virtual Carrier Sensing
clear;
DATA_RATE =[100 200 300 400 700 1000];
coll_cnt_dat_rat = zeros(1,3);
vcs_en = 0;
hidterminal = 0;
for dat_rt = 1 : 6

    FrameSlot = 0.00001; %Frame slot is 10ms. Correct to 0.00001 for 10us.
    DataSlot  = ceil((8000/8000000)/FrameSlot)   %Number of slots required for a packet in 8Mbps channel
    RUNTIME = 2;  %Run for 1 mSec
    NumFrames_A = DATA_RATE(dat_rt)*RUNTIME;     %Number of frames generated
    NumFrames_C = DATA_RATE(dat_rt)*RUNTIME;
    RandGen_A   = rand(1, NumFrames_A);          %Random numbers from [0...1]
    RandGen_C   = rand(1, NumFrames_C);

    CWMIN_A     = 4;
    CWMIN_C     = 4;
    CW_A        = 4;
    CW_C        = 4;
    CWMAX_A     = 1024;
    CWMAX_C     = 1024;

    BKP_CNT_A   = 0;
    BKP_CNT_C   = 0;
    A_backedup  = 0;
    C_backedup  = 0;
    bkoff_diffAC = 0;
    A_has_pkt = 0;
    C_has_pkt = 0;
    A_tidx    = 1;
    C_tidx    = 1;


    CollAC       = zeros(1,1);

    CollCnt      = 0;
    coll_det  = 0;
    A_tran_suc = 0;
    C_tran_suc = 0;


    %Generate the Poisson Arrival Time for A and C
    X_A = -(log(1-RandGen_A))/DATA_RATE(dat_rt);
    X_C = -(log(1-RandGen_C))/DATA_RATE(dat_rt);

    X_A_pkt_arr_time = zeros(1, NumFrames_A);
    X_C_pkt_arr_time = zeros(1, NumFrames_C);
    X_A_pkt_arr_time(1) = X_A(1);
    X_C_pkt_arr_time(1) = X_C(1);

    %Generate the actual time events when the packets are arrived for
    %transmission
    for i = 2: NumFrames_A
        X_A_pkt_arr_time(i) = X_A_pkt_arr_time(i-1) + X_A_pkt_arr_time(i) + X_A(i);
    end

    for i = 2: NumFrames_C
        X_C_pkt_arr_time(i) = X_C_pkt_arr_time(i-1) + X_C_pkt_arr_time(i) + X_C(i);
    end


    start_time = 0.0;
    sim_time = 0.0;
    %Generate the paket generation events
    NumSlots = (RUNTIME/FrameSlot) % Remove this 100

    i =0;
    while(i < NumSlots)
        %  fprintf("Num of slot proceedes is %d \n", i );
        i = i + 4;
        sim_time = i*FrameSlot;
        A_has_pkt = (A_tidx < DATA_RATE(dat_rt)) &&  (X_A_pkt_arr_time(A_tidx) < sim_time);
        C_has_pkt = (C_tidx < DATA_RATE(dat_rt)) &&  (X_C_pkt_arr_time(C_tidx) < sim_time);
        % fprintf("Sim Time is %f, %f, %f \n", X_A_pkt_arr_time(A_tidx), X_C_pkt_arr_time(C_tidx), sim_time );
        % fprintf("Packet Index is %f, %f, \n", A_tidx, C_tidx );
        %/////////////////////////////////////////////////////////////////////////////////////////////////////////
        %A and C has packet to transmit
        %/////////////////////////////////////////////////////////////////////////////////////////////////////////
        if(A_has_pkt && C_has_pkt)
            [i, BKP_CNT_A, BKP_CNT_C, coll_det, A_tran_suc, C_tran_suc, CW_A, CW_C ] = calc_new_simtime_AandC_transmit(i, vcs_en, hidterminal, A_backedup, C_backedup, CW_A, CW_C , DataSlot, BKP_CNT_A, BKP_CNT_C,X_A_pkt_arr_time, X_C_pkt_arr_time, A_tidx, C_tidx );
            if (coll_det) CollCnt = CollCnt + 1;
            elseif (A_tran_suc) A_tidx = A_tidx + 1;
            elseif (C_tran_suc) C_tidx = C_tidx + 1;
            end
          
           %fprintf("Packet Index is %f, %f, \n", A_tidx, C_tidx );
           
            
        elseif (A_has_pkt)
             [i, BKP_CNT_A, BKP_CNT_C, coll_det, A_tran_suc, C_tran_suc ] = calc_new_simtime_A_transmit(i, vcs_en, A_backedup, C_backedup, CW_A, CW_C , DataSlot, BKP_CNT_A, BKP_CNT_C);
             A_tidx = A_tidx + 1;
        elseif (C_has_pkt)
            [i, BKP_CNT_A, BKP_CNT_C, coll_det, A_tran_suc, C_tran_suc ] = calc_new_simtime_C_transmit(i, vcs_en, A_backedup, C_backedup, CW_A, CW_C , DataSlot, BKP_CNT_A, BKP_CNT_C);
             C_tidx = C_tidx + 1;

        end
       end % While loop

       end % For loop
       fprintf("Packet Index is %f, %f, \n", A_tidx, C_tidx );
       %plot(DATA_RATE, coll_cnt_dat_rat(1,:))

        %end
    
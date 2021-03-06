function plotSimWM_RecRnd_MultiTrials_att(my_task_id)

%% Move to correct directory
if ispc,
    base_dir = 'B:\Projects\Models of Working Memory\Recurrent-Random Networks\RecRnd Multi Simulations';
elseif isunix,
    base_dir = '/jukebox/buschman/Projects/Models of Working Memory/Recurrent-Random Networks/RecRnd Multi Simulations';
end
cd(base_dir);

%% Convert task id into parameters setting
sim.NumPools = 8;
sim.RndRec_f = [0 0.025 0.050 0.075 0.100 0.150 0.200 0.250 0.300 0.400 0.500 0.750 1.000];
sim.RecToRndW_TargetFR = [0.25];
sim.RndToRecW_TargetFR = [0.22];
sim.RecWPositiveWidth = [0.75 1 1.5];
sim.NumInputs = [1:4 6 8];
sim.N_rnd = [512 1024];

length(sim.RndToRecW_TargetFR)*length(sim.RecToRndW_TargetFR)*length(sim.RecWPositiveWidth)*length(sim.N_rnd)

%mysim.RndRec_f = sim.RndRec_f(mod(my_task_id, length(sim.RndRec_f))+1);
%my_task_id = floor(my_task_id./length(sim.RndRec_f));
mysim.RecToRndW_TargetFR = sim.RecToRndW_TargetFR(mod(my_task_id, length(sim.RecToRndW_TargetFR))+1);
my_task_id = floor(my_task_id./length(sim.RecToRndW_TargetFR));
mysim.RndToRecW_TargetFR = sim.RndToRecW_TargetFR(mod(my_task_id, length(sim.RndToRecW_TargetFR))+1);
my_task_id = floor(my_task_id./length(sim.RndToRecW_TargetFR));
mysim.RecWPositiveWidth = sim.RecWPositiveWidth(mod(my_task_id, length(sim.RecWPositiveWidth))+1);
my_task_id = floor(my_task_id./length(sim.RecWPositiveWidth));
%mysim.NumInputs = sim.NumInputs(mod(my_task_id, length(sim.NumInputs))+1);
%my_task_id = floor(my_task_id./length(sim.NumInputs));
mysim.N_rnd = sim.N_rnd(mod(my_task_id, length(sim.N_rnd))+1);

my_save_dir = sprintf('Plots for SimWM_Nrnd%04.0f_TargetFR%03.0f_%03.0f_RecPosWidth%03.0f', ...
    mysim.N_rnd, mysim.RecToRndW_TargetFR*100, mysim.RndToRecW_TargetFR*100, mysim.RecWPositiveWidth*100);
	
if ~exist(my_save_dir, 'dir'),
    mkdir(my_save_dir);
end


%% Process simulations
vect_thresh = 3;
time = [0:(1/1000):1.5];

ovr_peak_rel_ang = NaN*ones(length(time), length(sim.RndRec_f), length(sim.NumInputs));
ovr_peak_width = NaN*ones(length(time), length(sim.RndRec_f), length(sim.NumInputs));
ovr_peak_prom = NaN*ones(length(time), length(sim.RndRec_f), length(sim.NumInputs));

ovr_vect_len = NaN*ones(length(time), length(sim.RndRec_f), length(sim.NumInputs));
ovr_vect_len_prct = NaN*ones(length(time), length(sim.RndRec_f), length(sim.NumInputs));
ovr_vect_rel_ang = NaN*ones(length(time), length(sim.RndRec_f), length(sim.NumInputs));
ovr_vect_rel_ang_std = NaN*ones(length(time), length(sim.RndRec_f), length(sim.NumInputs));
ovr_vect_rel_ang_rem = NaN*ones(length(time), length(sim.RndRec_f), length(sim.NumInputs));
ovr_vect_rel_ang_rem_std = NaN*ones(length(time), length(sim.RndRec_f), length(sim.NumInputs));

ovr_vm_rel_ang = NaN*ones(length(time), length(sim.RndRec_f), sim.NumPools, length(sim.NumInputs));
ovr_vm_rel_ang_std = NaN*ones(length(time), length(sim.RndRec_f), sim.NumPools, length(sim.NumInputs));
ovr_vm_circvar = NaN*ones(length(time), length(sim.RndRec_f), sim.NumPools, length(sim.NumInputs));
ovr_vm_circvar_std = NaN*ones(length(time), length(sim.RndRec_f), sim.NumPools, length(sim.NumInputs));
ovr_vm_height = NaN*ones(length(time), length(sim.RndRec_f), sim.NumPools, length(sim.NumInputs));
ovr_vm_height_std = NaN*ones(length(time), length(sim.RndRec_f), sim.NumPools, length(sim.NumInputs));
ovr_vm_good_prct = NaN*ones(length(time), length(sim.RndRec_f), sim.NumPools, length(sim.NumInputs));
ovr_vm_rel_ang_good = NaN*ones(length(time), length(sim.RndRec_f), length(sim.NumInputs));
ovr_vm_circvar_good = NaN*ones(length(time), length(sim.RndRec_f), length(sim.NumInputs));
ovr_vm_height_good = NaN*ones(length(time), length(sim.RndRec_f), length(sim.NumInputs));

for cur_f_ind = 1:length(sim.RndRec_f),
    cur_f = sim.RndRec_f(cur_f_ind);
    for cur_input_ind = 1:length(sim.NumInputs),
        cur_input = sim.NumInputs(cur_input_ind);
        
        my_save_fn = sprintf('SimWM_Nrnd%04.0f_f%04.0f_TargetFR%03.0f_%03.0f_RecPosWidth%03.0f_Inputs%1.0f.mat', ...
            mysim.N_rnd, cur_f*1000, mysim.RecToRndW_TargetFR*100, mysim.RndToRecW_TargetFR*100, mysim.RecWPositiveWidth*100, cur_input);

        warning off;
        %inp = matfile(my_save_fn);
        inp = load(my_save_fn);
        opts = inp.opts(1, 1);
        
        ovr_peak_width(:, cur_f_ind, cur_input_ind) = nanmean(inp.MemPeakWidth(:, 1, :)/opts.N_rec*2*pi, 3);
        ovr_peak_prom(:, cur_f_ind, cur_input_ind) = nanmean(inp.MemPeakProm(:, 1, :), 3);
        ovr_peak_rel_ang(:, cur_f_ind, cur_input_ind) = nanmean(abs(inp.MemPeakAngleRel(:, 1, :)), 3);
        
        temp_ang_rel = squeeze(inp.MemVect_AngRel(:, 1, :));
        temp_vect_len = squeeze(inp.MemVect_Len(:, 1, :));
        
        ovr_vect_len(:, cur_f_ind, cur_input_ind) = nanmean(temp_vect_len, 2);
        ovr_vect_len_prct(:, cur_f_ind, cur_input_ind) = nanmean(temp_vect_len >= vect_thresh, 2);
        
        ovr_vect_rel_ang(:, cur_f_ind, cur_input_ind) = nanmean(abs(temp_ang_rel), 2);
        ovr_vect_rel_ang_std(:, cur_f_ind, cur_input_ind) = nanstd(abs(temp_ang_rel), [], 2);
        for i = 1:size(temp_vect_len, 1),
            ovr_vect_rel_ang_rem(i, cur_f_ind, cur_input_ind) = nanmean(abs(temp_ang_rel(i, temp_vect_len(i, :) >= vect_thresh)), 2);
            ovr_vect_rel_ang_rem_std(i, cur_f_ind, cur_input_ind) = nanstd(abs(temp_ang_rel(i, temp_vect_len(i, :) >= vect_thresh)), [], 2);
        end
        
        for i = 1:sim.NumPools,
            ovr_vm_rel_ang(:, cur_f_ind, i, cur_input_ind) = nanmean(abs(squeeze(inp.MemVonMises_AngRel(:, i, :))), 2);
            ovr_vm_rel_ang_std(:, cur_f_ind, i, cur_input_ind) = nanstd(abs(squeeze(inp.MemVonMises_AngRel(:, i, :))), [], 2);
            ovr_vm_circvar(:, cur_f_ind, i, cur_input_ind) = nanmean(squeeze(inp.MemVonMises_CircVar(:, i, :)), 2);
            ovr_vm_circvar_std(:, cur_f_ind, i, cur_input_ind) = nanstd(squeeze(inp.MemVonMises_CircVar(:, i, :)), [], 2);
            ovr_vm_height(:, cur_f_ind, i, cur_input_ind) = nanmean(squeeze(inp.MemVonMises_Height(:, i, :)), 2);
            ovr_vm_height_std(:, cur_f_ind, i, cur_input_ind) = nanstd(squeeze(inp.MemVonMises_Height(:, i, :)), [], 2);
            
            %Determine whether this is considered a 'good' memory
            temp_vm_rel = squeeze(inp.MemVonMises_AngRel(:, i, :));
            temp_vm_circvar = squeeze(inp.MemVonMises_CircVar(:, i, :));
            temp_vm_len = squeeze(inp.MemVonMises_Height(:, i, :));
            
            good_ind = squeeze(abs(convn(convn(inp.MemVect_Len(:, i, :), ones(5, 1, 1)./5, 'same') >= vect_thresh, ones(20, 1)./20, 'same') - 1) <= 10*eps);
            %good_ind = (temp_vm_len >= 10) & (temp_vm_circvar <= 0.15);
            ovr_vm_good_prct(:, cur_f_ind, i, cur_input_ind) = sum(good_ind, 2)./sum(~isnan(inp.MemVect_Len(:, i, :)), 3);
            if i == 1,
                for j = 1:size(good_ind, 1),
                    if ~any(good_ind(j, :)), continue; end
                    ovr_vm_rel_ang_good(j, cur_f_ind, cur_input_ind) = nanmean(temp_vm_rel(j, good_ind(j, :)), 2);
                    ovr_vm_circvar_good(j, cur_f_ind, cur_input_ind) = nanmean(temp_vm_circvar(j, good_ind(j, :)), 2);
                    ovr_vm_height_good(j, cur_f_ind, cur_input_ind) = nanmean(temp_vm_len(j, good_ind(j, :)), 2);
                end
            end
        end
        
        warning on;
        fprintf('Processed %3.2f-%d\n', cur_f, cur_input);
    end
end
warning off;
t = inp.t;
warning on;
clear inp;

save([my_save_dir filesep 'SimWM_RecRnd_MultiTrials_ProcessedData.mat']);

%% Plot results of simulations
close all;

if ~exist('ovr_vect_len', 'var'), load([my_save_dir filesep 'SimWM_RecRnd_MultiTrials_ProcessedData.mat']); end

item_leg_str = {};
for cur_input_ind = 1:length(sim.NumInputs),
    cur_input = sim.NumInputs(cur_input_ind);
    item_leg_str{cur_input_ind} = sprintf('%d item%c', cur_input, 's'*(cur_input > 1));
end
recpool_leg_str = cellfun(@(x) sprintf('Rec Pool %d', x), num2cell([1:8]'), 'UniformOutput', false);

% Effect of connectivity on memory accuracy measurements
for i = 1:size(ovr_vect_rel_ang, 3),
    figure;
    imagesc(t, [1:length(sim.RndRec_f)], ovr_vect_rel_ang(:, :, i)');
    set(gca, 'YTick', [1:length(sim.RndRec_f)], 'YTickLabel', sim.RndRec_f);
    xlabel('Time (ms)'); ylabel('Connectivity fraction');
    title(sprintf('Impact of Connectivity on Mnemonic Accuracy (Vector Rel Ang) with %d items', sim.NumInputs(i)));
    set(gca, 'CLim', [0 pi/2]); colorbar;
    saveas(gcf, [my_save_dir filesep sprintf('MnemonicAccuracyByf_VectRelAng_%ditems.svg', sim.NumInputs(i))]);
    saveas(gcf, [my_save_dir filesep sprintf('MnemonicAccuracyByf_VectRelAng_%ditems.fig', sim.NumInputs(i))]);
end

for i = 1:size(ovr_peak_rel_ang, 3),
    figure;
    imagesc(t, [1:length(sim.RndRec_f)], ovr_peak_rel_ang(:, :, i)');
    set(gca, 'YTick', [1:length(sim.RndRec_f)], 'YTickLabel', sim.RndRec_f);
    xlabel('Time (ms)'); ylabel('Connectivity fraction');
    title(sprintf('Impact of Connectivity on Mnemonic Accuracy (Peak Rel Ang) with %d items', sim.NumInputs(i)));
    set(gca, 'CLim', [0 pi/2]); colorbar;
    saveas(gcf, [my_save_dir filesep sprintf('MnemonicAccuracyByf_PeakRelAng_%ditems.svg', sim.NumInputs(i))]);
    saveas(gcf, [my_save_dir filesep sprintf('MnemonicAccuracyByf_PeakRelAng_%ditems.fig', sim.NumInputs(i))]);
end

for i = 1:size(ovr_peak_width, 3),
    figure;
    imagesc(t, [1:length(sim.RndRec_f)], ovr_peak_width(:, :, i)');
    set(gca, 'YTick', [1:length(sim.RndRec_f)], 'YTickLabel', sim.RndRec_f);
    xlabel('Time (ms)'); ylabel('Connectivity fraction');
    title(sprintf('Impact of Connectivity on Mnemonic Accuracy (Peak Width) with %d items', sim.NumInputs(i)));
    set(gca, 'CLim', [0 pi/2]); colorbar;
    saveas(gcf, [my_save_dir filesep sprintf('MnemonicAccuracyByf_PeakWidth_%ditems.svg', sim.NumInputs(i))]);
    saveas(gcf, [my_save_dir filesep sprintf('MnemonicAccuracyByf_PeakWidth_%ditems.fig', sim.NumInputs(i))]);
end

for i = 1:size(ovr_peak_prom, 3),
    figure;
    imagesc(t, [1:length(sim.RndRec_f)], ovr_peak_prom(:, :, i)');
    set(gca, 'YTick', [1:length(sim.RndRec_f)], 'YTickLabel', sim.RndRec_f);
    xlabel('Time (ms)'); ylabel('Connectivity fraction');
    title(sprintf('Impact of Connectivity on Mnemonic Accuracy (Peak Prominence) with %d items', sim.NumInputs(i)));
    colorbar;
    saveas(gcf, [my_save_dir filesep sprintf('MnemonicAccuracyByf_PeakProm_%ditems.svg', sim.NumInputs(i))]);
    saveas(gcf, [my_save_dir filesep sprintf('MnemonicAccuracyByf_PeakProm_%ditems.fig', sim.NumInputs(i))]);
end

for i = 1:size(ovr_vect_len, 3),
    figure;
    subplot(1,2,1);
    imagesc(t, [1:length(sim.RndRec_f)], ovr_vect_len(:, :, i)');
    set(gca, 'YTick', [1:length(sim.RndRec_f)], 'YTickLabel', sim.RndRec_f);
    xlabel('Time (ms)'); ylabel('Connectivity fraction');
    title(sprintf('Impact of Connectivity on Mnemonic Accuracy (Vector Length) with %d items', sim.NumInputs(i)));
    colorbar;
    
    subplot(1,2,2);
    imagesc(t, [1:length(sim.RndRec_f)], ovr_vect_len_prct(:, :, i)');
    set(gca, 'YTick', [1:length(sim.RndRec_f)], 'YTickLabel', sim.RndRec_f);
    xlabel('Time (ms)'); ylabel('Connectivity fraction');
    title(sprintf('Impact of Connectivity on Mnemonic Accuracy (Percent of Vector Length >= Thresh [%2.1e]) with %d items', vect_thresh, sim.NumInputs(i)));
    colorbar;
    
    saveas(gcf, [my_save_dir filesep sprintf('MnemonicAccuracyByf_VectLen_%ditems.svg', sim.NumInputs(i))]);
    saveas(gcf, [my_save_dir filesep sprintf('MnemonicAccuracyByf_VectLen_%ditems.fig', sim.NumInputs(i))]);
end

for i = 1:size(ovr_vm_rel_ang, 4),
    figure;
    imagesc(t, [1:length(sim.RndRec_f)], ovr_vm_rel_ang(:, :, 1, i)');
    set(gca, 'YTick', [1:length(sim.RndRec_f)], 'YTickLabel', sim.RndRec_f);
    xlabel('Time (ms)'); ylabel('Connectivity fraction');
    title(sprintf('Impact of Connectivity on Mnemonic Accuracy (Von Mises Relative Angle) with %d items', sim.NumInputs(i)));
    colorbar;
    saveas(gcf, [my_save_dir filesep sprintf('MnemonicAccuracyByf_VonMisesRelAng_%ditems.svg', sim.NumInputs(i))]);
    saveas(gcf, [my_save_dir filesep sprintf('MnemonicAccuracyByf_VonMisesRelAng_%ditems.fig', sim.NumInputs(i))]);
end

for i = 1:size(ovr_vm_circvar, 4),
    figure;
    imagesc(t, [1:length(sim.RndRec_f)], ovr_vm_circvar(:, :, 1, i)');
    set(gca, 'YTick', [1:length(sim.RndRec_f)], 'YTickLabel', sim.RndRec_f);
    xlabel('Time (ms)'); ylabel('Connectivity fraction');
    title(sprintf('Impact of Connectivity on Mnemonic Accuracy (Von Mises Circular Variance) with %d items', sim.NumInputs(i)));
    colorbar;
    saveas(gcf, [my_save_dir filesep sprintf('MnemonicAccuracyByf_VonMisesCircVar_%ditems.svg', sim.NumInputs(i))]);
    saveas(gcf, [my_save_dir filesep sprintf('MnemonicAccuracyByf_VonMisesCircVar_%ditems.fig', sim.NumInputs(i))]);
end

for i = 1:size(ovr_vm_height, 4),
    figure;
    imagesc(t, [1:length(sim.RndRec_f)], ovr_vm_height(:, :, 1, i)');
    set(gca, 'YTick', [1:length(sim.RndRec_f)], 'YTickLabel', sim.RndRec_f);
    xlabel('Time (ms)'); ylabel('Connectivity fraction');
    title(sprintf('Impact of Connectivity on Mnemonic Accuracy (Von Mises Amp) with %d items', sim.NumInputs(i)));
    colorbar;
    saveas(gcf, [my_save_dir filesep sprintf('MnemonicAccuracyByf_VonMisesAmp_%ditems.svg', sim.NumInputs(i))]);
    saveas(gcf, [my_save_dir filesep sprintf('MnemonicAccuracyByf_VonMisesAmp_%ditems.fig', sim.NumInputs(i))]);
end

for i = 1:size(ovr_vm_good_prct, 4),
    figure;
    imagesc(t, [1:length(sim.RndRec_f)], ovr_vm_good_prct(:, :, i)');
    set(gca, 'YTick', [1:length(sim.RndRec_f)], 'YTickLabel', sim.RndRec_f);
    xlabel('Time (ms)'); ylabel('Connectivity fraction');
    title(sprintf('Impact of Connectivity on Recall of Item with %d items', sim.NumInputs(i)));
    colorbar;
    saveas(gcf, [my_save_dir filesep sprintf('MnemonicAccuracyByf_VonMisesMem_%ditems.svg', sim.NumInputs(i))]);
    saveas(gcf, [my_save_dir filesep sprintf('MnemonicAccuracyByf_VonMisesMem_%ditems.fig', sim.NumInputs(i))]);
end


% Collapse across time (and include standard deviations)
figure;
plot(sim.RndRec_f, squeeze(nanmean(ovr_vect_rel_ang((t >= 0.3) & (t < 0.8), :, :), 1))');
hold on;
%plot(sim.RndRec_f, squeeze(nanmean(ovr_vect_rel_ang((t >= 0.3) & (t < 0.8), :, :), 1))' + squeeze(nanmean(ovr_vect_rel_ang_std((t >= 0.3) & (t < 0.8), :, :), 1))', ':');
%plot(sim.RndRec_f, squeeze(nanmean(ovr_vect_rel_ang((t >= 0.3) & (t < 0.8), :, :), 1))' - squeeze(nanmean(ovr_vect_rel_ang_std((t >= 0.3) & (t < 0.8), :, :), 1))', ':');
%set(gca, 'XTick', [1:length(sim.RndRec_f)], 'XTickLabel', sim.RndRec_f);
xlabel('Connectivity fraction'); ylabel('Average |Vector Angle Offset|');
legend(item_leg_str);
title('Effect of Connectivity on Mnemonic Accuracy (Abs Vector Offset)');
saveas(gcf, [my_save_dir filesep 'MnemonicAccuracyByf_VectRelAng_all.svg']);
saveas(gcf, [my_save_dir filesep 'MnemonicAccuracyByf_VectRelAng_all.fig']);

figure;
plot(sim.RndRec_f, squeeze(nanmean(ovr_vect_rel_ang_rem((t >= 0.3) & (t < 0.8), :, :), 1))');
hold on;
%plot(sim.RndRec_f, squeeze(nanmean(ovr_vect_rel_ang_rem((t >= 0.3) & (t < 0.8), :, :), 1))' + squeeze(nanmean(ovr_vect_rel_ang_rem_std((t >= 0.3) & (t < 0.8), :, :), 1))', ':');
%plot(sim.RndRec_f, squeeze(nanmean(ovr_vect_rel_ang_rem((t >= 0.3) & (t < 0.8), :, :), 1))' - squeeze(nanmean(ovr_vect_rel_ang_rem_std((t >= 0.3) & (t < 0.8), :, :), 1))', ':');
%set(gca, 'XTick', [1:length(sim.RndRec_f)], 'XTickLabel', sim.RndRec_f);
xlabel('Connectivity fraction'); ylabel('Average |Vector Angle Offset| of Remembered Stimuli');
legend(item_leg_str);
title('Effect of Connectivity on Mnemonic Accuracy (Abs Vector Offset of /Remembered/ Stimuli)');
saveas(gcf, [my_save_dir filesep 'MnemonicAccuracyByf_VectRelAngRem_all.svg']);
saveas(gcf, [my_save_dir filesep 'MnemonicAccuracyByf_VectRelAngRem_all.fig']);

figure;
plot(sim.RndRec_f, squeeze(nanmean(ovr_vect_len((t >= 0.3) & (t < 0.8), :, :), 1))');
%set(gca, 'XTick', [1:length(sim.RndRec_f)], 'XTickLabel', sim.RndRec_f);
xlabel('Connectivity fraction'); ylabel('Average Vector Length');
legend(item_leg_str);
title('Effect of Connectivity on Mnemonic Accuracy (Vector Length)');
saveas(gcf, [my_save_dir filesep 'MnemonicAccuracyByf_VectLen_all.svg']);
saveas(gcf, [my_save_dir filesep 'MnemonicAccuracyByf_VectLen_all.fig']);

figure;
plot(sim.RndRec_f, squeeze(nanmean(ovr_peak_width((t >= 0.3) & (t < 0.8), :, :), 1))');
%set(gca, 'XTick', [1:length(sim.RndRec_f)], 'XTickLabel', sim.RndRec_f);
xlabel('Connectivity fraction'); ylabel('Average Peak Width');
legend(item_leg_str);
title('Effect of Connectivity on Mnemonic Accuracy (Peak Width)');
saveas(gcf, [my_save_dir filesep 'MnemonicAccuracyByf_PeakWidth_all.svg']);
saveas(gcf, [my_save_dir filesep 'MnemonicAccuracyByf_PeakWidth_all.fig']);

figure;
plot([1:length(sim.RndRec_f)], squeeze(nanmean(ovr_vect_len_prct((t >= 0.3) & (t < 0.8), :, :), 1))');
set(gca, 'XTick', [1:length(sim.RndRec_f)], 'XTickLabel', sim.RndRec_f);
xlabel('Connectivity fraction'); ylabel('Percent Vector Length >= Thresh');
legend(item_leg_str);
title('Effect of Connectivity on Mnemonic Accuracy (Percent Vector Length >= Thresh)');
saveas(gcf, [my_save_dir filesep 'MnemonicAccuracyByf_VectLenPrct_all.svg']);
saveas(gcf, [my_save_dir filesep 'MnemonicAccuracyByf_VectLenPrct_all.fig']);


figure;
plot(sim.RndRec_f, squeeze(nanmean(ovr_vm_rel_ang((t >= 0.3) & (t < 0.8), :, 1, :), 1))');
%set(gca, 'XTick', [1:length(sim.RndRec_f)], 'XTickLabel', sim.RndRec_f);
xlabel('Connectivity fraction'); ylabel('Average Relative Angle');
legend(item_leg_str);
title('Effect of Connectivity on Mnemonic Accuracy (Von Mises Rel Ang)');
saveas(gcf, [my_save_dir filesep 'MnemonicAccuracyByf_VonMisesRelAng_all.svg']);
saveas(gcf, [my_save_dir filesep 'MnemonicAccuracyByf_VonMisesRelAng_all.fig']);

figure;
plot(sim.RndRec_f, squeeze(nanmean(ovr_vm_circvar((t >= 0.3) & (t < 0.8), :, 1, :), 1))');
%set(gca, 'XTick', [1:length(sim.RndRec_f)], 'XTickLabel', sim.RndRec_f);
xlabel('Connectivity fraction'); ylabel('Average Circular Variance');
legend(item_leg_str);
title('Effect of Connectivity on Mnemonic Accuracy (Von Mises Circ Var)');
saveas(gcf, [my_save_dir filesep 'MnemonicAccuracyByf_VonMisesCircVar_all.svg']);
saveas(gcf, [my_save_dir filesep 'MnemonicAccuracyByf_VonMisesCircVar_all.fig']);

figure;
plot(sim.RndRec_f, squeeze(nanmean(ovr_vm_height((t >= 0.3) & (t < 0.8), :, 1, :), 1))');
%set(gca, 'XTick', [1:length(sim.RndRec_f)], 'XTickLabel', sim.RndRec_f);
xlabel('Connectivity fraction'); ylabel('Average Peak Amplitude');
legend(item_leg_str);
title('Effect of Connectivity on Mnemonic Accuracy (Von Mises Amp)');
saveas(gcf, [my_save_dir filesep 'MnemonicAccuracyByf_VonMisesAmp_all.svg']);
saveas(gcf, [my_save_dir filesep 'MnemonicAccuracyByf_VonMisesAmp_all.fig']);

figure;
plot(sim.RndRec_f, squeeze(nanmean(ovr_vm_good_prct((t >= 0.3) & (t < 0.8), :, 1, :), 1))');
%set(gca, 'XTick', [1:length(sim.RndRec_f)], 'XTickLabel', sim.RndRec_f);
xlabel('Connectivity fraction'); ylabel('Percent ''Remembered''');
legend(item_leg_str);
title('Effect of Connectivity on Mnemonic Accuracy (Von Mises Remember)');
saveas(gcf, [my_save_dir filesep 'MnemonicAccuracyByf_VonMisesPrctRem_all.svg']);
saveas(gcf, [my_save_dir filesep 'MnemonicAccuracyByf_VonMisesPrctRem_all.fig']);

figure;
plot(sim.RndRec_f, squeeze(nanmean(ovr_vm_circvar_good((t >= 0.3) & (t < 0.8) & (t < 0.8), :, :), 1))');
%set(gca, 'XTick', [1:length(sim.RndRec_f)], 'XTickLabel', sim.RndRec_f);
xlabel('Connectivity fraction'); ylabel('Average Circular Variance of Remembered Items');
legend(item_leg_str);
title('Effect of Connectivity on Mnemonic Accuracy (Von Mises Circ Var) for REMEMBERED Items');
saveas(gcf, [my_save_dir filesep 'MnemonicAccuracyByf_VonMisesCircVarRem_all.svg']);
saveas(gcf, [my_save_dir filesep 'MnemonicAccuracyByf_VonMisesCircVarRem_all.fig']);

%Plot the mnemonic accuracy, percent remembered, and percent of phantom
%memories
figure;
for i = 1:length(sim.NumInputs),
    subplot(ceil(length(sim.NumInputs)/2),2,i);
    plot(sim.RndRec_f, squeeze(nanmean(ovr_vm_good_prct((t >= 0.3) & (t < 0.8) & (t < 0.8), :, :, i)))');
    xlabel('Connectivity fraction'); ylabel('Percent ''Remembered''');
    legend(recpool_leg_str);
    title(sprintf('Effect of Connectivity on Mnemonic Accuracy (Von Mises %% Remembered) - %d Items Stored', sim.NumInputs(i)));
end
saveas(gcf, [my_save_dir filesep 'MnemonicAccuracyByf_VonMisesPrctRem_allRings.svg']);
saveas(gcf, [my_save_dir filesep 'MnemonicAccuracyByf_VonMisesPrctRem_allRings.fig']);

fprintf('Finished plotting figures for WM model simulations...\n');
const countClasses =
	"text-xl font-bold basis-1/6 flex flex-col items-center gap-2";

export function newUploadSummary(studentCount: number) {
	const summary = document.createElement("div");
	summary.innerHTML = `
		<div id="upload_summary" class="border-2 border-main rounded p-3 flex flex-wrap justify-center">
			<h1 class="text-3xl font-bold w-full text-secondary">Upload Status</h1>
			<div class="${countClasses}">
				<h3 class="text-secondary">Success</h3>
				<p id="success_count" class="text-success">0</p>
			</div>
			<div class="${countClasses}">
				<h3 class="text-secondary">Error</h3>
				<p id="error_count" class="text-danger">0</p>
			</div>
			<div class="${countClasses}">
				<h3 class="text-secondary">Pending</h3>
				<p id="pending_count" class="text-slate-300">${studentCount}</p>
			</div>
			<div class="${countClasses}">
				<h3 class="text-secondary">Invalid</h3>
				<p id="invalid_count" class="text-orange-300">0</p>
			</div>
			<div class="${countClasses}">
				<h3 class="text-secondary">Total</h3>
				<p id="total_count" class="text-secondary">${studentCount}</p>
			</div>
		</div>
	`;
	return summary;
}

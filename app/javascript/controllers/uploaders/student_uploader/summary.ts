const countClasses =
	"text-xl font-bold basis-1/6 flex flex-col items-center gap-2";

export function newUploadSummary(studentCount: number) {
	const summary = document.createElement("div");
	summary.innerHTML = `
		<div id="upload_summary" class="flex flex-wrap justify-center">
			<h1 class="text-3xl font-bold w-full">Upload Status</h1>
			<div id="success_count" class="text-green-500 ${countClasses}">
				<h3>Success</h3>
				<p>0</p>
			</div>
			<div id="error_count" class="text-red-500 ${countClasses}">
				<h3>Error</h3>
				<p>0</p>
			</div>
			<div id="pending_count" class="text-slate-500 ${countClasses}">
				<h3>Pending</h3>
				<p>${studentCount}</p>
			</div>
			<div id="invalid_count" class="text-yellow-300 ${countClasses}">
				<h3>Invalid</h3>
				<p>0</p>
			</div>
			<div id="total_count" class="text-color-main ${countClasses}">
				<h3>Total</h3>
				<p>${studentCount}</p>
			</div>
		</div>
	`;
	return summary;
}
